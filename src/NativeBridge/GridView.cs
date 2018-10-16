using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Reflection;
using System.Diagnostics;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using PSmacOS.Cmdlets;

namespace PSmacOS.NativeBridge
{
    public class GridView
    {
        private static Process _gridViewerProcess = null;

        private static List<PSObject> objects = new List<PSObject>();

        private static List<int> selectedIndexes = new List<int>();

        public static void Start(string title, OutputModeOption outputMode, PSCmdlet cmdlet)
        {
            _gridViewerProcess = new Process();

            _gridViewerProcess.StartInfo.FileName = System.IO.Path.Combine(System.IO.Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "GridViewer.app", "Contents", "MacOS", "GridViewer");

            _gridViewerProcess.StartInfo.CreateNoWindow = true;
            _gridViewerProcess.StartInfo.UseShellExecute = false;

            _gridViewerProcess.StartInfo.RedirectStandardInput = true;
            _gridViewerProcess.StartInfo.RedirectStandardOutput = true;
            _gridViewerProcess.StartInfo.RedirectStandardError = true;

            // Just Console.WriteLine it.
            _gridViewerProcess.OutputDataReceived += (sender, data) =>
            {
                if (!string.IsNullOrWhiteSpace(data.Data))
                {
                    selectedIndexes.Add(Convert.ToInt32(data.Data));
                }
            };
            _gridViewerProcess.ErrorDataReceived += (sender, data) =>
            {
            };

            try
            {
                _gridViewerProcess.Start();
                _gridViewerProcess.BeginOutputReadLine();
                _gridViewerProcess.BeginErrorReadLine();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);

                Console.WriteLine(ex.Message);

                Console.WriteLine(ex.StackTrace);

            }
        }

        public static void AddRecord(PSObject obj)
        {
            objects.Add(obj);

            var recordJson = PSObjectHelper.ToJson(obj);
            //Console.WriteLine("Writing to stdin {0}", recordJson);
            _gridViewerProcess.StandardInput.WriteLine(recordJson);

        }

        public static List<PSObject> GetSelectedItems() {
            var selectedObjects = new List<PSObject>();
            foreach (var index in selectedIndexes) {
                selectedObjects.Add(objects[index]);
            }
            return selectedObjects;
        }

        public static void Close() 
        {   
            _gridViewerProcess.Close();
        }

        public static bool IsClosed() 
        {
            if (_gridViewerProcess == null || _gridViewerProcess.HasExited)
            { 
                return true; 
            }
            else {
                return false;
            }
        }

        public static void WaitForExit()
        {
            _gridViewerProcess.WaitForExit();
        }
    }
}