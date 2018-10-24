using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UseLitjson
{
	public class Skill
	{
		public int id { get; set; }
		public string name { get; set; }
		public int demage { get; set; }


		public override string ToString()
		{
			return "Id:" + id + "Name:" + name + "Demage:" + demage;
		}
	}
}
