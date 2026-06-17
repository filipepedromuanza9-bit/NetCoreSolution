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
    public partial class MenuPrincipal : Form
    {
        public MenuPrincipal()
        {
            InitializeComponent();
        }

        private void panel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void MenuPrincipal_Load(object sender, EventArgs e)
        {
            lblBemVindo.Text = "Bem-vindo, " + Form1.NomeFuncionario + " - " + Form1.Role;

            // Controle de acesso
            if (Form1.Role == "Vendedor")
            {
                btnCadastroFunc.Enabled = false;
                btnCadastroProd.Enabled = false;
            }
            else if (Form1.Role == "Gestor")
            {
                btnCadastroFunc.Enabled = false; // Só Admin cadastra funcionário
                btnCadastroProd.Enabled = true;
            }
            // Admin vê tudo
        }

        private void btnCadastroFunc_Click(object sender, EventArgs e)
        {
            FrmCadastroFuncionario frm = new FrmCadastroFuncionario();
            frm.ShowDialog();
        }

        private void btnCadastroProd_Click(object sender, EventArgs e)
        {
             FrmCadastroProduto frm = new FrmCadastroProduto();
            frm.ShowDialog();
        }

        private void btnVendas_Click(object sender, EventArgs e)
        {
            FrmVendas frm = new FrmVendas();
            frm.ShowDialog();
        }

        private void btnCadastroCliente_Click(object sender, EventArgs e)
        {
            FrmCadastroCliente frm = new FrmCadastroCliente();
            frm.ShowDialog();
        }

        private void btnRelatorio_Click(object sender, EventArgs e)
        {
           FrmRelatorioVendas frm = new FrmRelatorioVendas();
           frm.ShowDialog();
        }

        private void btnDetalhesVenda_Click(object sender, EventArgs e)
        {

            FrmBuscarVenda frm = new FrmBuscarVenda();
             frm.ShowDialog();

            //MessageBox.Show("Abra o Relatorio de Vendas e  Clicando 2x numa venda para ver os detalhes ,Agradeçemoçemos Caro Funcionario");
        }

        private void btnSair_Click(object sender, EventArgs e)
        {
        }
    }
    }

