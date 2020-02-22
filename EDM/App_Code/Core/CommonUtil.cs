using System;
using System.Text.RegularExpressions;

namespace HIT.OB.STD
{
    public static class CommonUtil
    {
        public static string ExtractFieldNameFromQuery(string query)
        {
            string _pattern = @"%.*?%";
            string field = string.Empty;
            foreach (Match _m in Regex.Matches(query, _pattern))
            {
                field += _m.ToString().Replace("%", "") + ",";
            }

            return field.TrimEnd(new char []{','});

        }

        public static string ToUpperFirstChar(this String str)
        {
            char firstChar = char.ToUpper(str[0]);
            if (str.Length > 1)
            {
                str = str.Substring(1, str.Length - 1);
            }
            else return firstChar.ToString();
            return firstChar + str;

        }
    }

    
}
