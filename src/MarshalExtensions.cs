using System;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;

namespace PSmacOS
{
    public static class MarshalExtensions
    {
        public static IntPtr NativeString(string managedString)
        {
            if (managedString != null)
            {
                int len = Encoding.UTF8.GetByteCount(managedString);
                byte[] buffer = new byte[len + 1];
                Encoding.UTF8.GetBytes(managedString, 0, managedString.Length, buffer, 0);
                IntPtr nativeUtf8 = Marshal.AllocHGlobal(buffer.Length);
                Marshal.Copy(buffer, 0, nativeUtf8, buffer.Length);
                return nativeUtf8;
            } else {
                return IntPtr.Zero;
            }
        }
        
        public static void FreeNativeString(IntPtr nativeString) {
            Marshal.FreeHGlobal(nativeString);
        }

        public static IntPtr[] NativeArray(string[] managedArray)
        {
            if (managedArray != null && managedArray.Length != 0)
            {
                IntPtr[] nativeArray = new IntPtr[managedArray.Length];
                for (int i = 0; i < managedArray.Length; i++)
                {
                    string managedString = managedArray[i];
                    IntPtr nativeString = NativeString(managedString);
                    nativeArray[i] = nativeString;
                }
                return nativeArray;
            }
            else
            {
                return new IntPtr[0];
            }
        }

        public static void FreeNativeArray(IntPtr[] nativeArray)
        {
            foreach (IntPtr s in nativeArray) {
                FreeNativeString(s);
            }
        }

        public static string ManagedString(IntPtr nativeUtf8)
        {
            if (nativeUtf8 != IntPtr.Zero)
            {
                int len = 0;
                while (Marshal.ReadByte(nativeUtf8, len) != 0) ++len;
                byte[] buffer = new byte[len];
                Marshal.Copy(nativeUtf8, buffer, 0, buffer.Length);
                return Encoding.UTF8.GetString(buffer);
            } else {
                return null;
            }
        }
    }
}