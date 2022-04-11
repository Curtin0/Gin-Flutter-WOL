using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;

namespace PortCMD
{
    /// <summary>
    /// 。net配置文件读取类
    /// </summary>
    public class ConfigurationHelper
    {
        static Configuration config = System.Configuration.ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

        /// <summary>
        /// 添加/修改键值对
        /// </summary>
        /// <param name="key"></param>
        /// <param name="value"></param>
        public static void AppSettingsAddOrUpdate(string key, string @value)
        {
            if (AppSettingsExistKey(key))
            {
                config.AppSettings.Settings[key].Value = @value;
            }
            else
            {
                config.AppSettings.Settings.Add(key, @value);
            }
        }

        /// <summary>
        /// 获取键值
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public static string AppSettingsGet(string key)
        {
            return config.AppSettings.Settings[key].Value;
        }

        /// <summary>
        /// 是否存在该键值
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public static bool AppSettingsExistKey(string key)
        {

            return config.AppSettings.Settings.AllKeys.Any(m => string.Compare(m, key, true) == 0);
        }

        /// <summary>
        /// 删除键值
        /// </summary>
        /// <param name="key"></param> 
        /// <returns></returns>
        public static void AppSettingsRemove(string key)
        {
            config.AppSettings.Settings.Remove(key);
        }

        /// <summary>
        /// 做完所有操作后必须调用这个方法保存
        /// </summary>
        public static void Save()
        {
            //一定要记得保存，写不带参数的config.Save()也可以
            config.Save(ConfigurationSaveMode.Modified);
            //刷新，否则程序读取的还是之前的值（可能已装入内存）
            System.Configuration.ConfigurationManager.RefreshSection("appSettings");
        }

    }

}
