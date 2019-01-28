using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;
using System.Collections.Generic;
using System.Collections;

namespace PSmacOS.Cmdlets
{
    [Cmdlet(VerbsCommon.Show, "MessageBox",DefaultParameterSetName = "SwitchButtons")]
    public class ShowMessageBox : PSCmdlet
    {
        [Parameter(Mandatory = false, ParameterSetName = "SwitchButtons")]
        [Parameter(Mandatory = false, ParameterSetName = "AnyButtons")]
        public string Title { get; set; } = string.Empty;

        [Parameter(Mandatory = true, ParameterSetName = "SwitchButtons")]
        [Parameter(Mandatory = true, ParameterSetName = "AnyButtons")]
        [ValidateNotNullOrEmpty()]
        public string Message { get; set; }

        [Parameter(Mandatory = false, ParameterSetName = "SwitchButtons")]
        [Parameter(Mandatory = false, ParameterSetName = "AnyButtons")]
        public double Timeout { get; set; } = 0;

        [Parameter(Mandatory = false, ParameterSetName = "SwitchButtons")]
        [Parameter(Mandatory = false, ParameterSetName = "AnyButtons")]
        public NativeBridge.MessageBox.Type Type { get; set; } = NativeBridge.MessageBox.Type.Plain;


        [Parameter(Mandatory = false, ParameterSetName = "AnyButtons")]
        public string ButtonOneLabel { get; set; } = "Ok";

        [Parameter(Mandatory = false, ParameterSetName = "AnyButtons")]
        public string ButtonTwoLabel { get; set; } = null;

        [Parameter(Mandatory = false, ParameterSetName = "AnyButtons")]
        public string ButtonThreeLabel { get; set; } = null;

        [Parameter(Mandatory = false, ParameterSetName = "SwitchButtons")]
        [ValidateSet("AbortRetryIgnore","OK", "OKCancel", "RetryCancel", "YesNo", "YesNoCancel")]
        public string Buttons { get; set; } = "Ok";

        protected override void ProcessRecord()
        {
               if (ParameterSetName == "SwitchButtons") {
                switch (Buttons.ToLowerInvariant()) {
                    case "abortretryignore":
                        ButtonOneLabel = "Abort";
                        ButtonTwoLabel = "Retry";
                        ButtonThreeLabel = "Ignore";
                        break;
                    case "ok":
                        ButtonOneLabel = "OK";
                        break;
                    case "okcancel":
                        ButtonOneLabel = "OK";
                        ButtonTwoLabel = "Cancel";
                        break;
                    case "retrycancel":
                        ButtonOneLabel = "Retry";
                        ButtonTwoLabel = "Cancel";
                        break;
                    case "yesno":
                        ButtonOneLabel = "Yes";
                        ButtonTwoLabel = "No";
                        break;
                    case "yesnocancel":
                        ButtonOneLabel = "Yes";
                        ButtonTwoLabel = "No";
                        ButtonThreeLabel = "Cancel";
                        break;
                }
            }

            var buttonPressed = NativeBridge.MessageBox.Show(Timeout, Type, Title, Message, ButtonOneLabel, ButtonTwoLabel, ButtonThreeLabel);
            switch (buttonPressed) {
                case 0:
                case 1:
                case 2:
                    WriteObject(buttonPressed+1);
                    break;
                case 3: // timeout
                    WriteObject(0);
                    break;
            }
        }
    }
}
