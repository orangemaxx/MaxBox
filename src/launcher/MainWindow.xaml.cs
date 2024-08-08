using System.Diagnostics;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace launcher
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void Quit(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
        private void Play(object sender, RoutedEventArgs e)
        {
            Process gameStart = new Process();
            List<string> args = new List<string>();
            args.Add(webserverip.ToString()); args.Add(serverport.ToString()); args.Add(localip.ToString()); args.Add(localPort.ToString());
            // TODO: Add Startup Args
            gameStart.StartInfo.FileName = "game/maxbox.exe";
            gameStart.Start();
            this.Close();
        }
        private void Server(object sender, RoutedEventArgs e)
        {
            Process.Start("explorer.exe", "server");
        }

        private void webserverip_TextChanged(object sender, TextChangedEventArgs e)
        {

        }
    }
}