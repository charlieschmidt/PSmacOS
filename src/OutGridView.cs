using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;
using System.Collections.Generic;
using System.Collections;

namespace PSmacOS
{
    [Cmdlet(VerbsData.Out, "GridView")]
    [Alias("ogv")]
    public class OutGridView : Cmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        [AllowNull]
        public PSObject InputObject { get; set; }
        
        protected override void BeginProcessing()
        {
            NativeBridge.GridView.Start();
        }

        protected override void ProcessRecord() 
        {
            NativeBridge.GridView.AddRecord(InputObject);
        }

        protected override void EndProcessing()
        {
            NativeBridge.GridView.End();
        }
    }
}
