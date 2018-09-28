using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;

namespace PSmacOS
{
	[OutputType(typeof(string))]
    [Cmdlet(VerbsCommon.Get, "Clipboard")]
    public class GetClipboard : Cmdlet
    {
        protected override void ProcessRecord()
        {
            var clipboard = NativeBridge.GetClipboard();
            
            WriteObject($"{clipboard}");
        }
    }


    [OutputType(typeof(string))]
    [Cmdlet(VerbsCommon.Set, "Clipboard")]
    public class SetClipboard : Cmdlet
    {
        protected override void ProcessRecord()
        {
            
        }
    }
}