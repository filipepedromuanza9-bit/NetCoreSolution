using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing.Printing;
using System.Drawing;
using System.Linq;
using System.Data.SqlClient; 
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SistamaVendasMercado
{
    public partial class FrmRelatorioVendas : Form
    {
        public FrmRelatorioVendas()
        {
            InitializeComponent();
        }

        private void btnGerar_Click(object sender, EventArgs e)
        {
            lvRelatorio.Items.Clear();
            using (SqlConnection con = Conexao.ObterConexao())
            {
                string sql = @"SELECT V.VendaID, C.Nome as Cliente, F.Nome as Vendedor, V.DataVenda, V.TotalVenda
                       FROM Vendas V
                       LEFT JOIN Clientes C ON V.ClienteID = C.ClienteID
                       LEFT JOIN Funcionarios F ON V.FuncionarioID = F.FuncionarioID
                       WHERE V.DataVenda BETWEEN @inicio AND @fim
                       ORDER BY V.DataVenda DESC";

                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@inicio", dtInicio.Value.Date);
                cmd.Parameters.AddWithValue("@fim", dtFim.Value.Date.AddDays(1));

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                foreach (DataRow row in dt.Rows)
                {
                    ListViewItem item = new ListViewItem(row["VendaID"].ToString());
                    item.SubItems.Add(row["Cliente"].ToString());
                    item.SubItems.Add(row["Vendedor"].ToString());
                    item.SubItems.Add(Convert.ToDateTime(row["DataVenda"]).ToString("dd/MM/yyyy HH:mm"));
                    item.SubItems.Add(Convert.ToDecimal(row["TotalVenda"]).ToString("0.00"));
                    lvRelatorio.Items.Add(item);
                }
            }
        }

        private void lvRelatorio_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (lvRelatorio.SelectedItems.Count > 0)
            {
                int idVenda = int.Parse(lvRelatorio.SelectedItems[0].Text);
                FrmDetalhesVenda frm = new FrmDetalhesVenda(idVenda);
                frm.ShowDialog();
            }
        }

        private void btnImprimir_Click(object sender, EventArgs e)
        {
            PrintDocument pd = new PrintDocument();
            pd.PrintPage += (s, ev) =>
            {
                float y = 20;
                ev.Graphics.DrawString("RELATÓRIO DE VENDAS", new System.Drawing.Font("Arial", 14, FontStyle.Bold), Brushes.Black, 180, y);
                y += 25;
                ev.Graphics.DrawString("Período: " + dtInicio.Value.ToShortDateString() + " até " + dtFim.Value.ToShortDateString(),
                    new System.Drawing.Font("Arial", 10), Brushes.Black, 10, y);
                y += 30;

                ev.Graphics.DrawString("Nº", new Font("Arial", 9, FontStyle.Bold), Brushes.Black, 10, y);
                ev.Graphics.DrawString("Cliente", new Font("Arial", 9, FontStyle.Bold), Brushes.Black, 50, y);
                ev.Graphics.DrawString("Vendedor", new Font("Arial", 9, FontStyle.Bold), Brushes.Black, 180, y);
                ev.Graphics.DrawString("Data", new Font("Arial", 9, FontStyle.Bold), Brushes.Black, 300, y);
                ev.Graphics.DrawString("Total", new Font("Arial", 9, FontStyle.Bold), Brushes.Black, 450, y);
                y += 20;

                decimal totalGeral = 0;
                foreach (ListViewItem item in lvRelatorio.Items)
                {
                    ev.Graphics.DrawString(item.SubItems[0].Text, new Font("Arial", 9), Brushes.Black, 10, y);
                    ev.Graphics.DrawString(item.SubItems[1].Text, new Font("Arial", 9), Brushes.Black, 50, y);
                    ev.Graphics.DrawString(item.SubItems[2].Text, new Font("Arial", 9), Brushes.Black, 180, y);
                    ev.Graphics.DrawString(item.SubItems[3].Text, new Font("Arial", 9), Brushes.Black, 300, y);
                    ev.Graphics.DrawString(item.SubItems[4].Text, new Font("Arial", 9), Brushes.Black, 450, y);
                    totalGeral += decimal.Parse(item.SubItems[4].Text);
                    y += 20;

                    if (y > 750) // quebra de página simples
                    {
                        ev.HasMorePages = true;
                        return;
                    }
                }

                y += 20;
                ev.Graphics.DrawString("TOTAL GERAL: " + totalGeral.ToString("0.00") + " Kz",
                    new Font("Arial", 12, FontStyle.Bold), Brushes.Black, 10, y);
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
    }
}
