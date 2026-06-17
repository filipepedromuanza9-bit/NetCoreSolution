using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SistamaVendasMercado
{
    public partial class FrmBuscarVenda : Form
    {
        public FrmBuscarVenda()
        {
            InitializeComponent();
        }

        private void btnAbrir_Click(object sender, EventArgs e)
        {
            int idVenda = 0;

            if (int.TryParse(txtIDVenda.Text, out  idVenda))
            {
                FrmDetalhesVenda frm = new FrmDetalhesVenda(idVenda);
                frm.ShowDialog();
                this.Close();
             }
                else
                {
                    MessageBox.Show(" Digite um ID valido.");
                }
            }

        private void btnVoltar_Click(object sender, EventArgs e)
        {
            MenuPrincipal menu = new MenuPrincipal();
            menu.ShowDialog();
        }
    }
    }

