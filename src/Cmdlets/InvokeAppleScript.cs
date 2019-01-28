using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;
using System.Collections.Generic;
using System.Collections;

namespace PSmacOS.Cmdlets
{
    [OutputType(typeof(string))]
    [Cmdlet(VerbsLifecycle.Invoke, "AppleScript")]
    public class InvokeAppleScript : Cmdlet
    {
        /// <summary>
        /// Script to execute
        /// </summary>
        [Parameter(Mandatory = true)]
        [ValidateNotNullOrEmpty]
        public string Script { get; set; }

        /// <summary>
        /// Function in script to run
        /// </summary>
        [Parameter(Mandatory = false)]
        [ValidateNotNullOrEmpty]
        public string FunctionName { get; set; }

        /// <summary>
        /// Function in script to run
        /// </summary>
        [Parameter(Mandatory = false)]
        [ValidateNotNullOrEmpty]
        public string[] Arguments { get; set; }

        protected override void BeginProcessing()
        {
            var response = NativeBridge.AppleScript.Execute(Script,FunctionName,Arguments);

            this.WriteObject(response, false);
        }
    }
}
