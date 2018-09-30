using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Reflection;
using System.Diagnostics;
using System.IO;

namespace PSmacOS
{
    public class NativeBridge
    {
        public class Clipboard
        {
            [DllImport("./libpsmacosbridging/build/lib/libpsmacosbridging")]
            internal extern static IntPtr getClipboard();

            [DllImport("./libpsmacosbridging/build/lib/libpsmacosbridging")]
            internal extern static bool setClipboard(IntPtr clipboardManagedString);

            [DllImport("./libpsmacosbridging/build/lib/libpsmacosbridging")]
            internal extern static void freeString(IntPtr managedString);

            public static string Get()
            {
                IntPtr clipboardManagedString = getClipboard();
                var clipboardString = MarshalExtensions.StringFromNativeUtf8(clipboardManagedString);
                freeString(clipboardManagedString);
                return clipboardString;
            }

            public static bool Set(string value)
            {
                var clipboardManagedString = MarshalExtensions.NativeUtf8FromString(value);
                var ret = setClipboard(clipboardManagedString);
                return ret;
            }
        }

        public class GridView
        {
            private static Process _gridViewerProcess = null;

            public static void End()
            {
                Console.WriteLine("Waiting for gv to exit");
                _gridViewerProcess.WaitForExit();
            }

            public static void AddRecord(PSObject obj)
            {
                Console.WriteLine("Writing to stdin {0}", obj.ToString());
                string recordCliXml = PSSerializer.Serialize(obj).Replace("\n", "");
                _gridViewerProcess.StandardInput.WriteLine(recordCliXml);
            }

            public static void Start()
            {
                _gridViewerProcess = new Process();

                _gridViewerProcess.StartInfo.FileName = "dotnet";
                _gridViewerProcess.StartInfo.Arguments = "GridViewer.dll";
                _gridViewerProcess.StartInfo.WorkingDirectory = System.IO.Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

                _gridViewerProcess.StartInfo.CreateNoWindow = true;
                _gridViewerProcess.StartInfo.UseShellExecute = false;

                _gridViewerProcess.StartInfo.RedirectStandardInput = true;
                _gridViewerProcess.StartInfo.RedirectStandardOutput = true;
                _gridViewerProcess.StartInfo.RedirectStandardError = true;

                // Just Console.WriteLine it.
                _gridViewerProcess.OutputDataReceived += (sender, data) =>
                {
                    Console.WriteLine(data.Data);
                };
                _gridViewerProcess.ErrorDataReceived += (sender, data) =>
                {
                    Console.WriteLine(data.Data);
                };


                Console.WriteLine("Starting GridViewer from nativeBridge");
                _gridViewerProcess.Start();
                _gridViewerProcess.BeginOutputReadLine();
                _gridViewerProcess.BeginErrorReadLine();
                Console.WriteLine("Started GridViewer from nativeBridge");

            }
        }

        public class MessageBox {
            public enum Type {
                Stop = 0,
                Note = 1,
                Caution = 2,
                Plain = 3
            }

            [DllImport("./libpsmacosbridging/build/lib/libpsmacosbridging")]
            internal extern static ulong showMessageBox(double timeoutSeconds, ulong type, IntPtr title, IntPtr message, IntPtr buttonOneLabel, IntPtr buttonTwoLabel, IntPtr buttonThreeLabel);

            public static ulong Show(double timeoutSeconds, MessageBox.Type type, string title, string message, string buttonOneLabel, string buttonTwoLabel, string buttonThreeLabel) 
            {
                var titleManagedString = MarshalExtensions.NativeUtf8FromString(title); 
                var messageManagedString = MarshalExtensions.NativeUtf8FromString(message);
                var buttonOneLabelManagedString = MarshalExtensions.NativeUtf8FromString(buttonOneLabel);
                var buttonTwoLabelManagedString = MarshalExtensions.NativeUtf8FromString(buttonTwoLabel);
                var buttonThreeLabelManagedString = MarshalExtensions.NativeUtf8FromString(buttonThreeLabel);

                ulong response = showMessageBox(timeoutSeconds, Convert.ToUInt64(type), titleManagedString, messageManagedString, buttonOneLabelManagedString, buttonTwoLabelManagedString, buttonThreeLabelManagedString);

                return response;
            }
        } 
    }
}