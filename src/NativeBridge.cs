using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;

namespace PSmacOS
{
    public class NativeBridge
    {
        public class Clipboard
        {
            [DllImport("./Native/build/lib/libpsmacosbridging")]
            internal extern static IntPtr getClipboard();

            [DllImport("./Native/build/lib/libpsmacosbridging")]
            internal extern static bool setClipboard(IntPtr clipboardManagedString);

            [DllImport("./Native/build/lib/libpsmacosbridging")]
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

        public class MessageBox {
            public enum Type {
                Stop = 0,
                Note = 1,
                Caution = 2,
                Plain = 3
            }

            [DllImport("./Native/build/lib/libpsmacosbridging")]
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