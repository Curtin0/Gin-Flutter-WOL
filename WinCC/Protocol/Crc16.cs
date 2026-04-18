using System;
using System.Text;

namespace WinCC.Protocol
{
    /// <summary>
    /// CRC16 Modbus校验工具
    /// </summary>
    public static class Crc16
    {
        private const ushort Polynomial = 0xA001;
        private const ushort InitialValue = 0xFFFF;

        /// <summary>
        /// 计算CRC16 Modbus校验 (从指定位置开始)
        /// </summary>
        /// <param name="data">要进行计算的字节数组</param>
        /// <param name="start">起始位置</param>
        /// <param name="length">要计算的长度</param>
        /// <returns>2字节校验码 (低位在前，高位在后)</returns>
        public static byte[] Calculate(byte[] data, int start, int length)
        {
            if (data == null || start < 0 || length <= 0 || start + length > data.Length)
            {
                throw new ArgumentException("Invalid data or length");
            }

            ushort crc = InitialValue;

            for (int i = start; i < start + length; i++)
            {
                crc ^= data[i];
                for (int j = 0; j < 8; j++)
                {
                    if ((crc & 0x0001) == 1)
                    {
                        crc >>= 1;
                        crc ^= Polynomial;
                    }
                    else
                    {
                        crc >>= 1;
                    }
                }
            }

            return new byte[] { (byte)(crc & 0x00FF), (byte)((crc & 0xFF00) >> 8) };
        }

        /// <summary>
        /// 计算CRC16 Modbus校验
        /// </summary>
        /// <param name="data">要进行计算的字节数组</param>
        /// <param name="length">要计算的长度</param>
        /// <returns>2字节校验码 (低位在前，高位在后)</returns>
        public static byte[] Calculate(byte[] data, int length)
        {
            if (data == null || length <= 0 || length > data.Length)
            {
                throw new ArgumentException("Invalid data or length");
            }

            ushort crc = InitialValue;

            for (int i = 0; i < length; i++)
            {
                crc ^= data[i];
                for (int j = 0; j < 8; j++)
                {
                    if ((crc & 0x0001) == 1)
                    {
                        crc >>= 1;
                        crc ^= Polynomial;
                    }
                    else
                    {
                        crc >>= 1;
                    }
                }
            }

            return new byte[] { (byte)(crc & 0x00FF), (byte)((crc & 0xFF00) >> 8) };
        }

        /// <summary>
        /// 计算完整字节数组的CRC16
        /// </summary>
        public static byte[] Calculate(byte[] data)
        {
            return Calculate(data, data.Length);
        }

        /// <summary>
        /// 验证CRC16校验
        /// </summary>
        /// <param name="data">完整数据（包含CRC）</param>
        /// <returns>校验是否通过</returns>
        public static bool Verify(byte[] data)
        {
            if (data == null || data.Length < 3)
            {
                return false;
            }

            var receivedCrc = new byte[] { data[data.Length - 2], data[data.Length - 1] };
            var calculatedCrc = Calculate(data, data.Length - 2);

            return receivedCrc[0] == calculatedCrc[0] && receivedCrc[1] == calculatedCrc[1];
        }

        /// <summary>
        /// 字节数组转十六进制字符串
        /// </summary>
        public static string ToHexString(byte[] data, string separator = " ")
        {
            if (data == null || data.Length == 0)
            {
                return string.Empty;
            }

            var sb = new StringBuilder(data.Length * 3);
            for (int i = 0; i < data.Length; i++)
            {
                if (i > 0) sb.Append(separator);
                sb.Append(data[i].ToString("X2"));
            }
            return sb.ToString();
        }
    }
}
