using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace WebCrawler.Application
{
    internal static class Extensions
    {
        public static string RemoveExtraSpaces(this string text)
        {
            bool preserveTabs = false;

            //[Step 1]: Clean up white spaces around the text
            text = text.Trim();
            //Console.Write("\nTrim\n======\n" + text);

            //[Step 2]: Reduce repeated spaces to single space.
            text = Regex.Replace(text, @" +", " ");

            //[Step 3]: Handle Tab spaces. Tabs needs to treated with care because
            //in some files tabs have special meaning (for eg Tab separated files)
            if (preserveTabs)
            {
                text = Regex.Replace(text, @" *\t *", "\t");
            }
            else
            {
                text = Regex.Replace(text, @"[ \t]+", " ");
            }

            //[Step 4]: Reduce repeated new lines (and other white spaces around them)
            //into a single line.
            text = Regex.Replace(text, @"([\t ]*(\n)+[\t ]*)+", " ");
            return text;
        }
    }
}