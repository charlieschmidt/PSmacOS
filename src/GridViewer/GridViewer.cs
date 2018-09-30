using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Management.Automation;
using System.Text;

namespace GridViewer
{
    class Program
    {
        [DllImport("./libpsmacosbridging/build/lib/libpsmacosbridging")]
        internal extern static IntPtr startGridView();

        static void Main(string[] args)
        {
            Console.WriteLine("Starting GridViewer from dotnet cli app");
            
            startGridView();
        }
    }
}
