using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LitJson;
using System.IO;

namespace UseLitjson
{
	class Program
	{
		static void Main(string[] args)
		{
			#region-------------------写入json---------------------------
			string path = "json.txt";

			List<Skill> list = new List<Skill>();
			
			Skill s = new Skill();
			s.id = 5;
			s.name = "龙凤呈祥";
			s.demage = 3000;
			list.Add(s);
			
			Skill sd = new Skill();
			sd.id = 6;
			sd.name = "天天向上";
			sd.demage = 5000;
			list.Add(sd);

			string jsonStr = JsonMapper.ToJson(list);
			File.WriteAllText(path, jsonStr);
			#endregion---------------------------------------------------

			#region------------------------读取json-----------------------
			Skill[] skillList = JsonMapper.ToObject<Skill[]>(File.ReadAllText("json.txt"));

			foreach (var a in skillList)
			{
				Console.WriteLine(a);
			}

			#endregion--------------------------------------------------
		}
	}
}
