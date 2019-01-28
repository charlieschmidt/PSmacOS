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


    public class MessageBox
    {
        public enum Type
        {
            Stop = 0,
            Note = 1,
            Caution = 2,
            Plain = 3
        }

        [DllImport("./libpsmacosbridging")]
        internal extern static ulong showMessageBox(double timeoutSeconds, ulong type, IntPtr title, IntPtr message, IntPtr buttonOneLabel, IntPtr buttonTwoLabel, IntPtr buttonThreeLabel);

        public static ulong Show(double timeoutSeconds, MessageBox.Type type, string title, string message, string buttonOneLabel, string buttonTwoLabel, string buttonThreeLabel)
        {
            var titleNativeString = MarshalExtensions.NativeString(title);
            var messageNativeString = MarshalExtensions.NativeString(message);
            var buttonOneLabelNativeString = MarshalExtensions.NativeString(buttonOneLabel);
            var buttonTwoLabelNativeString = MarshalExtensions.NativeString(buttonTwoLabel);
            var buttonThreeLabelNativeString = MarshalExtensions.NativeString(buttonThreeLabel);

            ulong response = showMessageBox(timeoutSeconds, Convert.ToUInt64(type), titleNativeString, messageNativeString, buttonOneLabelNativeString, buttonTwoLabelNativeString, buttonThreeLabelNativeString);

            MarshalExtensions.FreeNativeString(titleNativeString);
            MarshalExtensions.FreeNativeString(messageNativeString);
            MarshalExtensions.FreeNativeString(buttonOneLabelNativeString);
            MarshalExtensions.FreeNativeString(buttonTwoLabelNativeString);
            MarshalExtensions.FreeNativeString(buttonThreeLabelNativeString);

            return response;
        }
    }

}