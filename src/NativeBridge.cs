using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;

namespace PSmacOS
{
    public class NativeBridge
    {

        [DllImport("./Native/build/lib/libpsmacosbridging")]
        internal extern static IntPtr get_macos_clipboard();


        [DllImport("./Native/build/lib/libpsmacosbridging")]
        internal extern static bool set_macos_clipboard(IntPtr clipboardManagedString, int length);

        [DllImport("./Native/build/lib/libpsmacosbridging")]
        internal extern static void free_clipboard(IntPtr clipboardManagedString);

        public static string GetClipboard()
        {
            IntPtr clipboardManagedString = get_macos_clipboard();

            var clipboardString = MarshalExtensions.StringFromNativeUtf8(clipboardManagedString);

            free_clipboard(clipboardManagedString);

            return clipboardString;
        }

        public static bool SetClipboard(string value)
        {
            var clipboardManagedString = MarshalExtensions.NativeUtf8FromString(value);
            int length = Encoding.UTF8.GetByteCount(value);

            var ret = set_macos_clipboard(clipboardManagedString, length);

            return ret;
        }
    }
}