using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;
using System.Collections.Generic;
using System.Collections;

namespace PSmacOS.Cmdlets
{
	[OutputType(typeof(string))]
    [Cmdlet(VerbsCommon.Get, "Clipboard")]
    [Alias("gcb")]
    public class GetClipboard : Cmdlet
    {
        protected override void BeginProcessing()
        {
            var clipboard = NativeBridge.Clipboard.Get();
            WriteObject($"{clipboard}");
        }
    }


    [Cmdlet(VerbsCommon.Set, "Clipboard")]
    [Alias("scb")]
    public class SetClipboard : Cmdlet
    {
        private List<string> _contentList = new List<string>();

        [Parameter(Position = 0, Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
        [AllowNull]
        [AllowEmptyCollection]
        [AllowEmptyString]
        public string[] Value { get; set; }

        protected override void BeginProcessing()
        {
            _contentList.Clear();
        }

        protected override void ProcessRecord()
        {
            if (Value != null)
            {
                _contentList.AddRange(Value);
            }
        }

        protected override void EndProcessing()
        {
            if (_contentList != null)
            {
                var value = string.Join(Environment.NewLine, _contentList.ToArray(), 0, _contentList.Count);

                var ret = NativeBridge.Clipboard.Set(value);
            }
        }
    }
}