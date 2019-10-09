using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace WindowsUpdateTracker.Models
{
    public class WindowsUpdateModel
    {
        public int ID { get; set; }

        public string UpdateTitle { get; set; }

        public string HostName { get; set; }
        [DisplayFormat(DataFormatString = "{0:MM-dd-yyyy}", ApplyFormatInEditMode = true), DataType(DataType.Date)]
        public DateTime Date { get; set; }

        public string DownloadStatus { get; set; }

        public string InstallStatus { get; set; }
    }
}
