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
        protected override void BeginProcessing()
        {
        }
    }
}
