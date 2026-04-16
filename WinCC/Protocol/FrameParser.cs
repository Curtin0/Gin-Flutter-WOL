using System;
using System.Collections.Generic;

namespace WinCC.Protocol
{
    /// <summary>
    /// 帧解析器 - 用于从字节流中解析完整的帧
    /// 透传模式下主要作用是缓存和分帧
    /// </summary>
    public class FrameParser
    {
        private readonly byte[] _buffer;
        private int _bufferLength;

        // 有效从站地址范围 0x21-0x28
        private static readonly byte[] ValidAddresses = { 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28 };

        // 帧头标记
        private const byte FrameHead1 = 0x20;
        private const byte FrameHead2 = 0x01;

        public FrameParser(int bufferSize = 1024)
        {
            _buffer = new byte[bufferSize];
            _bufferLength = 0;
        }

        /// <summary>
        /// 解析数据，返回完整的帧列表
        /// </summary>
        public List<byte[]> Parse(byte[] data)
        {
            var frames = new List<byte[]>();

            if (data == null || data.Length == 0)
            {
                return frames;
            }

            // 将新数据加入缓冲区
            if (_bufferLength + data.Length > _buffer.Length)
            {
                // 缓冲区满，清空
                _bufferLength = 0;
            }

            Array.Copy(data, 0, _buffer, _bufferLength, data.Length);
            _bufferLength += data.Length;

            // 尝试解析完整帧
            int offset = 0;
            while (offset < _bufferLength)
            {
                // 查找帧头 0x20 0x01
                int frameStart = -1;
                for (int i = offset; i < _bufferLength - 1; i++)
                {
                    if (_buffer[i] == FrameHead1 && _buffer[i + 1] == FrameHead2)
                    {
                        frameStart = i;
                        break;
                    }
                }

                if (frameStart == -1)
                {
                    // 没有找到帧头，清空缓冲区
                    _bufferLength = 0;
                    break;
                }

                // 计算从帧头开始能解析的帧长度
                int remaining = _bufferLength - frameStart;

                // 帧格式: 0x20 0x01 [地址(1)] [功能码(1)] ... 
                // 最小帧长度检查
                if (remaining < 5)
                {
                    break;
                }

                byte address = _buffer[frameStart + 2];

                // 检查是否是有效地址
                bool validAddress = false;
                foreach (var addr in ValidAddresses)
                {
                    if (address == addr)
                    {
                        validAddress = true;
                        break;
                    }
                }

                if (!validAddress)
                {
                    // 地址无效，跳过这个帧头
                    offset = frameStart + 2;
                    continue;
                }

                // 根据功能码确定帧长度
                byte funcCode = _buffer[frameStart + 3];
                int frameLength = GetFrameLength(funcCode, remaining);

                if (frameLength > 0 && _bufferLength - frameStart >= frameLength)
                {
                    // 完整帧已接收
                    byte[] frame = new byte[frameLength];
                    Array.Copy(_buffer, frameStart, frame, 0, frameLength);
                    frames.Add(frame);

                    offset = frameStart + frameLength;
                }
                else
                {
                    // 帧不完整，等待更多数据
                    break;
                }
            }

            // 移动剩余数据到缓冲区开头
            if (offset > 0 && offset < _bufferLength)
            {
                int remaining = _bufferLength - offset;
                Array.Copy(_buffer, offset, _buffer, 0, remaining);
                _bufferLength = remaining;
            }
            else if (offset >= _bufferLength)
            {
                _bufferLength = 0;
            }

            return frames;
        }

        /// <summary>
        /// 根据功能码获取帧长度
        /// </summary>
        private int GetFrameLength(byte funcCode, int remaining)
        {
            switch (funcCode)
            {
                case 0x0F: // 初始化帧
                    return 12;
                case 0x0E: // 心跳帧
                    return 12;
                case 0x0D: // ID分配帧
                    return 12;
                case 0x2B: // 设备识别帧
                    return 42;
                case 0x41: // 正常运行帧
                    return 50;
                default:
                    return -1;
            }
        }

        /// <summary>
        /// 清空缓冲区
        /// </summary>
        public void Clear()
        {
            _bufferLength = 0;
        }
    }
}
