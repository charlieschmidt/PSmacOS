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
        internal extern static bool setClipboard(IntPtr clipboardNativeString);

        [DllImport("./libpsmacosbridging")]
        internal extern static void freeString(IntPtr nativeString);

        public static string Get()
        {
            IntPtr clipboardNativeString = getClipboard();
            var clipboardString = MarshalExtensions.ManagedString(clipboardNativeString);
            freeString(clipboardNativeString);
            return clipboardString;
        }

        public static bool Set(string value)
        {
            var clipboardNativeString = MarshalExtensions.NativeString(value);
            var ret = setClipboard(clipboardNativeString);
            MarshalExtensions.FreeNativeString(clipboardNativeString);
            return ret;
        }
    }
}