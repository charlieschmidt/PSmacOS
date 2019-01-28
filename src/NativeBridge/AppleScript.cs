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
    public class AppleScript
    {
        [DllImport("./libpsmacosbridging")]
        internal extern static IntPtr executeAppleScript(IntPtr appleScript, IntPtr functionName, IntPtr[] arguments, ulong argumentCount);

        [DllImport("./libpsmacosbridging")]
        internal extern static void freeString(IntPtr nativeString);

        public static string Execute(string appleScript, string functionName, string[] arguments)
        {
            var appleScriptManagedString = MarshalExtensions.NativeString(appleScript);
            var functionNameManagedString = MarshalExtensions.NativeString(functionName);
            var argumentsManagedArray = MarshalExtensions.NativeArray(arguments);

            IntPtr nativeResponse = executeAppleScript(appleScriptManagedString, functionNameManagedString, argumentsManagedArray, Convert.ToUInt64(arguments == null ? 0 : arguments.Length));

            var response = MarshalExtensions.ManagedString(nativeResponse);

            MarshalExtensions.FreeNativeArray(argumentsManagedArray);
            MarshalExtensions.FreeNativeString(appleScriptManagedString);
            MarshalExtensions.FreeNativeString(functionNameManagedString);

            return response;
        }
    }
}