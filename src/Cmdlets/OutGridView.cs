using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;
using System.Collections.Generic;
using System.Collections;
using System.Management.Automation.Internal;
using System.Management.Automation.Runspaces;

using Microsoft.PowerShell.Commands.Internal.Format;

// https://github.com/PowerShell/PowerShell/blob/a3786158ca51cd65388743f900b69ec9e253c3d9/src/Microsoft.PowerShell.Commands.Utility/commands/utility/FormatAndOutput/OutGridView/OutGridViewCommand.cs

namespace PSmacOS.Cmdlets
{
    /// <summary>
    /// Enum for SelectionMode parameter.
    /// </summary>
    public enum OutputModeOption
    {
        /// <summary>
        /// None is the default and it means OK and Cancel will not be present
        /// and no objects will be written to the pipeline.
        /// The selectionMode of the actual list will still be multiple.
        /// </summary>
        None,
        /// <summary>
        /// Allow selection of one single item to be written to the pipeline.
        /// </summary>
        Single,
        /// <summary>
        ///Allow select of multiple items to be written to the pipeline.
        /// </summary>
        Multiple
    }

    [Cmdlet(VerbsData.Out, "GridView",DefaultParameterSetName = "PassThru")]
    [Alias("ogv")]
    public class OutGridView : PSCmdlet
    {
        //private TypeInfoDataBase _typeInfoDataBase;
        //private PSPropertyExpressionFactory _expressionFactory;

        /// <summary>
        /// This parameter specifies the current pipeline object.
        /// </summary>
        [Parameter(ValueFromPipeline = true)]
        public PSObject InputObject { get; set; } = AutomationNull.Value;

        /// <summary>
        /// Gets/sets the title of the Out-GridView window.
        /// </summary>
        [Parameter]
        [ValidateNotNullOrEmpty]
        public string Title { get; set; }

        /// <summary>
        /// Get or sets a value indicating whether the cmdlet should wait for the window to be closed.
        /// </summary>
        [Parameter(ParameterSetName = "Wait")]
        public SwitchParameter Wait { get; set; }

        /// <summary>
        /// Get or sets a value indicating whether the selected items should be written to the pipeline
        /// and if it should be possible to select multiple or single list items.
        /// </summary>
        [Parameter(ParameterSetName = "OutputMode")]
        public OutputModeOption OutputMode { set; get; }

        /// <summary>
        /// Gets or sets a value indicating whether the selected items should be written to the pipeline.
        /// Setting this to true is the same as setting the OutputMode to Multiple.
        /// </summary>
        [Parameter(ParameterSetName = "PassThru")]
        public SwitchParameter PassThru
        {
            set { this.OutputMode = value.IsPresent ? OutputModeOption.Multiple : OutputModeOption.None; }
            get { return OutputMode == OutputModeOption.Multiple ? new SwitchParameter(true) : new SwitchParameter(false); }
        }


        /// <summary>
        /// Provides a one-time, pre-processing functionality for the cmdlet.
        /// </summary>
        protected override void BeginProcessing()
        {
            // Set up the ExpressionFactory
            //_expressionFactory = new PSPropertyExpressionFactory();

            // If the value of the Title parameter is valid, use it as a window's title.
            if (this.Title != null)
            {
                NativeBridge.GridView.Start(this.Title, OutputMode, this);
            }
            else
            {
                // Using the command line as a title.
                NativeBridge.GridView.Start(this.MyInvocation.Line, OutputMode, this);
            }

            // Load the Type info database.
            //_typeInfoDataBase = this.Context.FormatDBManager.GetTypeInfoDataBase();
        }



        /// <summary>
        /// Provides a record-by-record processing functionality for the cmdlet.
        /// </summary>
        protected override void ProcessRecord()
        {
            if (InputObject == null || InputObject == AutomationNull.Value)
            {
                return;
            }

            IDictionary dictionary = InputObject.BaseObject as IDictionary;
            if (dictionary != null)
            {
                // Dictionaries should be enumerated through because the pipeline does not enumerate through them.
                foreach (DictionaryEntry entry in dictionary)
                {
                    ProcessObject(PSObjectHelper.AsPSObject(entry));
                }
            }
            else
            {
                ProcessObject(InputObject);
            }
        }

        /// <summary>
        /// StopProcessing is called close the window when Ctrl+C in the command prompt.
        /// </summary>
        protected override void StopProcessing()
        {
            if (this.Wait || this.OutputMode != OutputModeOption.None)
            {
                NativeBridge.GridView.Close();
            }
        }

        /// <summary>
        /// Blocks depending on the wait and selected.
        /// </summary>
        protected override void EndProcessing()
        {
            base.EndProcessing();

            if (NativeBridge.GridView.IsClosed())
            {
                return;
            }

            // If -Wait is used or outputMode is not None we have to wait for the window to be closed
            // The pipeline will be blocked while we don't return
            if (this.Wait || this.OutputMode != OutputModeOption.None)
            {
                NativeBridge.GridView.WaitForExit();
            }

            // Output selected items to pipeline.
            List<PSObject> selectedItems = NativeBridge.GridView.GetSelectedItems();
            if (this.OutputMode != OutputModeOption.None && selectedItems != null)
            {
                foreach (PSObject selectedItem in selectedItems)
                {
                    if (selectedItem == null)
                    {
                        continue;
                    }
                    /* 
                    PSPropertyInfo originalObjectProperty = selectedItem.Properties[OutWindowProxy.OriginalObjectPropertyName];
                    if (originalObjectProperty == null)
                    {
                        return;
                    }
                    */
                    this.WriteObject(selectedItem, false);
                }
            }
        }

        private const string DataNotQualifiedForGridView = "DataNotQualifiedForGridView";
        /// <summary>
        /// Execute formatting on a single object.
        /// </summary>
        /// <param name="input">object to process</param>
        private void ProcessObject(PSObject input)
        {
            // Make sure the OGV window is not closed.
            if (NativeBridge.GridView.IsClosed())
            {
                /*
                LocalPipeline pipeline = (LocalPipeline)this.Context.CurrentRunspace.GetCurrentlyRunningPipeline();

                if (pipeline != null && !pipeline.IsStopping)
                {
                    // Stop the pipeline cleanly.
                    pipeline.StopAsync();
                }
                */
                return;
            }

            Object baseObject = input.BaseObject;

            // Throw a terminating error for types that are not supported.
            if (baseObject is ScriptBlock ||
                baseObject is SwitchParameter ||
                baseObject is PSReference ||
                baseObject is PSObject)
            {
                ErrorRecord error = new ErrorRecord(
                    new FormatException("The data format is not supported by Out-GridView."),
                    DataNotQualifiedForGridView,
                    ErrorCategory.InvalidType,
                    null);

                this.ThrowTerminatingError(error);
            }

            /*
            if (DefaultScalarTypes.IsTypeInList(input.TypeNames) ||
                              OutOfBandFormatViewManager.IsPropertyLessObject(input))
            {
                WriteVerbose("is scalar");
            } else {
                WriteVerbose("is not scalar");
            }
            */
            
            NativeBridge.GridView.AddRecord(InputObject);

            /*
            if (_gridHeader == null)
            {
                // Columns have not been added yet; Start the main window and add columns.
                _windowProxy.ShowWindow();
                _gridHeader = GridHeader.ConstructGridHeader(input, this);
            }
            else
            {
                _gridHeader.ProcessInputObject(input);
            }
            */

            /*
            // Some thread synchronization needed.
            Exception exception = _windowProxy.GetLastException();
            if (exception != null)
            {
                ErrorRecord error = new ErrorRecord(
                    exception,
                    "ManagementListInvocationException",
                    ErrorCategory.OperationStopped,
                    null);

                this.ThrowTerminatingError(error);
            }
            */
        }    
    }
}
