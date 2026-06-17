using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Data.SqlClient;
using System.Drawing.Printing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SistamaVendasMercado
{
    public partial class FrmDetalhesVenda : Form
    {
        int vendaID;
        decimal total = 0;

        public FrmDetalhesVenda(int idVenda)
        {
            InitializeComponent();
            vendaID = idVenda;
            lblVendaID.Text = "Venda Nº: " + vendaID;
            ConfigurarListView();
            CarregarDetalhes();
        }

        void ConfigurarListView()
        {
            lvDetalhes.View = View.Details;
            lvDetalhes.FullRowSelect = true;
            lvDetalhes.Columns.Add("Produto", 180);
            lvDetalhes.Columns.Add("Qtd", 50);
            lvDetalhes.Columns.Add("Preço Unit.", 80);
            lvDetalhes.Columns.Add("SubTotal", 80);
        }

        void CarregarDetalhes()
        {
            lvDetalhes.Items.Clear();
            total = 0;
            using (SqlConnection con = Conexao.ObterConexao())
            {
                string sql = @"SELECT P.NomeProduto, DV.Quantidade, DV.PrecoUnitario, DV.SubTotal
                               FROM DetalhesVenda DV
                               INNER JOIN Produtos P ON DV.ProdutoID = P.ProdutoID
                               WHERE DV.VendaID = @id";

                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@id", vendaID);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    ListViewItem item = new ListViewItem(dr["NomeProduto"].ToString());
                    item.SubItems.Add(dr["Quantidade"].ToString());
                    item.SubItems.Add(Convert.ToDecimal(dr["PrecoUnitario"]).ToString("0.00"));
                    item.SubItems.Add(Convert.ToDecimal(dr["SubTotal"]).ToString("0.00"));
                    lvDetalhes.Items.Add(item);
                    total += Convert.ToDecimal(dr["SubTotal"]);
                }
                lblTotal.Text = "Total da Venda: " + total.ToString("0.00") + " Kz";
            }
        }


        private void btnImprimir_Click(object sender, EventArgs e)
        {
            ImprimirDetalhes();
        }

        void ImprimirDetalhes()
        {
            PrintDocument pd = new PrintDocument();
            pd.PrintPage += (s, ev) =>
            {
                float y = 20;
                ev.Graphics.DrawString("DETALHES DA VENDA", new System.Drawing.Font("Arial", 14, System.Drawing.FontStyle.Bold), System.Drawing.Brushes.Black, 100, y);
                y += 30;
                ev.Graphics.DrawString(lblVendaID.Text, new System.Drawing.Font("Arial", 10), System.Drawing.Brushes.Black, 10, y);
                y += 25;

                ev.Graphics.DrawString("Produto", new System.Drawing.Font("Arial", 9, System.Drawing.FontStyle.Bold), System.Drawing.Brushes.Black, 10, y);
                ev.Graphics.DrawString("Qtd", new System.Drawing.Font("Arial", 9, System.Drawing.FontStyle.Bold), System.Drawing.Brushes.Black, 180, y);
                ev.Graphics.DrawString("SubTotal", new System.Drawing.Font("Arial", 9, System.Drawing.FontStyle.Bold), System.Drawing.Brushes.Black, 240, y);
                y += 20;

                foreach (ListViewItem item in lvDetalhes.Items)
                {
                    ev.Graphics.DrawString(item.SubItems[0].Text, new System.Drawing.Font("Arial", 9), System.Drawing.Brushes.Black, 10, y);
                    ev.Graphics.DrawString(item.SubItems[1].Text, new System.Drawing.Font("Arial", 9), System.Drawing.Brushes.Black, 180, y);
                    ev.Graphics.DrawString(item.SubItems[3].Text, new System.Drawing.Font("Arial", 9), System.Drawing.Brushes.Black, 240, y);
                    y += 20;
                }

                y += 20;
                ev.Graphics.DrawString(lblTotal.Text, new System.Drawing.Font("Arial", 12, System.Drawing.FontStyle.Bold), System.Drawing.Brushes.Black, 10, y);
            };

            PrintDialog pdialog = new PrintDialog();
            pdialog.Document = pd;
            if (pdialog.ShowDialog() == DialogResult.OK)
                pd.Print();
        }

        private void btnSair_Click(object sender, EventArgs e)
        {
            MenuPrincipal menu = new MenuPrincipal();
            menu.ShowDialog();
        }

        private void FrmDetalhesVenda_Load(object sender, EventArgs e)
        {

        }
    }
}