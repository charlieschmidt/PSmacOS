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

namespace PSmacOS.NativeBridge
{
    public class Clipboard
    {
        [DllImport("./libpsmacosbridging")]
        internal extern static IntPtr getClipboard();

        [DllImport("./libpsmacosbridging")]
        internal extern static bool setClipboard(IntPtr clipboardManagedString);

        [DllImport("./libpsmacosbridging")]
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
}