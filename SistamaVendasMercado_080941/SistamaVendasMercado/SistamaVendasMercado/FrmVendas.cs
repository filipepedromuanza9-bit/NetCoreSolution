using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Drawing.Printing;
using System.Data.SqlClient;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SistamaVendasMercado
{
    public partial class FrmVendas : Form
    {
        DataTable itens = new DataTable();
        decimal totalVenda = 0;
        int vendaID = 0;

        public FrmVendas()
        {
            InitializeComponent();
            ConfigurarTabelaItens();
            CarregarClientes();
            CarregarProdutos();
        }

        void ConfigurarTabelaItens()
        {
            itens.Columns.Add("ProdutoID", typeof(int));
            itens.Columns.Add("Produto", typeof(string));
            itens.Columns.Add("Qtd", typeof(int));
            itens.Columns.Add("Preco", typeof(decimal));
            itens.Columns.Add("SubTotal", typeof(decimal));

            lvItens.Columns.Add("Produto", 150);
            lvItens.Columns.Add("Qtd", 50);
            lvItens.Columns.Add("Preço", 80);
            lvItens.Columns.Add("SubTotal", 80);
        }

        void CarregarClientes()
        {
            using (SqlConnection con = Conexao.ObterConexao())
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT ClienteID, Nome FROM Clientes", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                cmbCliente.DataSource = dt;
                cmbCliente.DisplayMember = "Nome";
                cmbCliente.ValueMember = "ClienteID";
            }
        }

        void CarregarProdutos()
        {
            using (SqlConnection con = Conexao.ObterConexao())
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT ProdutoID, NomeProduto, PrecoUnitario, QuantidadeStock FROM Produtos WHERE QuantidadeStock > 0", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                cmbProduto.DataSource = dt;
                cmbProduto.DisplayMember = "NomeProduto";
                cmbProduto.ValueMember = "ProdutoID";
            }
        }

        private void cmbProduto_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cmbProduto.SelectedValue != null)
            {
                DataRowView drv = (DataRowView)cmbProduto.SelectedItem;
                txtPreco.Text = Convert.ToDecimal(drv["PrecoUnitario"]).ToString();
            }
        }

        private void btnAddItem_Click(object sender, EventArgs e)
        {
            int qtd = int.Parse(txtQtd.Text);
            decimal preco = decimal.Parse(txtPreco.Text);
            decimal subtotal = qtd * preco;

            itens.Rows.Add(cmbProduto.SelectedValue, cmbProduto.Text, qtd, preco, subtotal);
            totalVenda += subtotal;
            lblTotal.Text = "Total: " + totalVenda.ToString("0.00") + " Kz";

            // Atualiza ListView
            lvItens.Items.Clear();
            foreach (DataRow row in itens.Rows)
            {
                ListViewItem item = new ListViewItem(row["Produto"].ToString());
                item.SubItems.Add(row["Qtd"].ToString());
                item.SubItems.Add(Convert.ToDecimal(row["Preco"]).ToString("0.00"));
                item.SubItems.Add(Convert.ToDecimal(row["SubTotal"]).ToString("0.00"));
                lvItens.Items.Add(item);
            }

            txtQtd.Clear();
        }

        private void btnFinalizar_Click(object sender, EventArgs e)
        {

            if (itens.Rows.Count == 0)
            {
                MessageBox.Show("Adicione pelo menos 1 item");
                return;
            }

            using (SqlConnection con = Conexao.ObterConexao())
            {
                con.Open();
                SqlTransaction trans = con.BeginTransaction();

                try
                {
                    // 1. Insere na tabela Vendas
                    string sqlVenda = "INSERT INTO Vendas (ClienteID, FuncionarioID, TotalVenda) OUTPUT INSERTED.VendaID VALUES (@cli, @func, @total)";
                    SqlCommand cmdVenda = new SqlCommand(sqlVenda, con, trans);
                    cmdVenda.Parameters.AddWithValue("@cli", cmbCliente.SelectedValue);
                    cmdVenda.Parameters.AddWithValue("@func", Form1.FuncionarioID);
                    cmdVenda.Parameters.AddWithValue("@total", totalVenda);
                    vendaID = (int)cmdVenda.ExecuteScalar();

                    // 2. Insere itens e baixa stock
                    foreach (DataRow row in itens.Rows)
                    {
                        string sqlDetalhe = "INSERT INTO DetalhesVenda (VendaID, ProdutoID, Quantidade, PrecoUnitario) VALUES (@venda, @prod, @qtd, @preco)";
                        SqlCommand cmdDet = new SqlCommand(sqlDetalhe, con, trans);
                        cmdDet.Parameters.AddWithValue("@venda", vendaID);
                        cmdDet.Parameters.AddWithValue("@prod", row["ProdutoID"]);
                        cmdDet.Parameters.AddWithValue("@qtd", row["Qtd"]);
                        cmdDet.Parameters.AddWithValue("@preco", row["Preco"]);
                        cmdDet.ExecuteNonQuery();

                        string sqlUpdateStock = "UPDATE Produtos SET QuantidadeStock = QuantidadeStock - @qtd WHERE ProdutoID = @prod";
                        SqlCommand cmdStock = new SqlCommand(sqlUpdateStock, con, trans);
                        cmdStock.Parameters.AddWithValue("@qtd", row["Qtd"]);
                        cmdStock.Parameters.AddWithValue("@prod", row["ProdutoID"]);
                        cmdStock.ExecuteNonQuery();
                    }

                    trans.Commit();
                    MessageBox.Show("Venda finalizada! Nº " + vendaID);
                    ImprimirComprovativo(vendaID);
                    LimparVenda();
                }
                catch (Exception ex)
                {
                    trans.Rollback();
                    MessageBox.Show("Erro: " + ex.Message);
                }
            }
        }

        void ImprimirComprovativo(int idVenda)
        {
            PrintDocument pd = new PrintDocument();
            pd.PrintPage += (s, ev) =>
            {
                float y = 20;
                ev.Graphics.DrawString("SUPERMERCADO SISTEMA", new System.Drawing.Font("Arial", 14, System.Drawing.FontStyle.Bold), System.Drawing.Brushes.Black, 100, y);
                y += 30;
                ev.Graphics.DrawString("Venda Nº: " + idVenda, new System.Drawing.Font("Arial", 10), System.Drawing.Brushes.Black, 10, y);
                y += 20;
                ev.Graphics.DrawString("Cliente: " + cmbCliente.Text, new System.Drawing.Font("Arial", 10), System.Drawing.Brushes.Black, 10, y);
                y += 20;
                ev.Graphics.DrawString("Data: " + DateTime.Now.ToString(), new System.Drawing.Font("Arial", 10), System.Drawing.Brushes.Black, 10, y);
                y += 30;

                ev.Graphics.DrawString("Produto", new System.Drawing.Font("Arial", 9, System.Drawing.FontStyle.Bold), System.Drawing.Brushes.Black, 10, y);
                ev.Graphics.DrawString("Qtd", new System.Drawing.Font("Arial", 9, System.Drawing.FontStyle.Bold), System.Drawing.Brushes.Black, 150, y);
                ev.Graphics.DrawString("SubTotal", new System.Drawing.Font("Arial", 9, System.Drawing.FontStyle.Bold), System.Drawing.Brushes.Black, 200, y);
                y += 20;

                foreach (DataRow row in itens.Rows)
                {
                    ev.Graphics.DrawString(row["Produto"].ToString(), new System.Drawing.Font("Arial", 9), System.Drawing.Brushes.Black, 10, y);
                    ev.Graphics.DrawString(row["Qtd"].ToString(), new System.Drawing.Font("Arial", 9), System.Drawing.Brushes.Black, 150, y);
                    ev.Graphics.DrawString(Convert.ToDecimal(row["SubTotal"]).ToString("0.00"), new System.Drawing.Font("Arial", 9), System.Drawing.Brushes.Black, 200, y);
                    y += 20;
                }

                y += 20;
                ev.Graphics.DrawString("TOTAL: " + totalVenda.ToString("0.00") + " Kz", new System.Drawing.Font("Arial", 12, System.Drawing.FontStyle.Bold), System.Drawing.Brushes.Black, 10, y);
            };

            PrintDialog pdialog = new PrintDialog();
            pdialog.Document = pd;
            if (pdialog.ShowDialog() == DialogResult.OK)
                pd.Print();
        }

        void LimparVenda()
        {
            itens.Rows.Clear();
            lvItens.Items.Clear();
            totalVenda = 0;
            lblTotal.Text = "Total: 0.00 Kz";
        }

        private void Sair_Click(object sender, EventArgs e)
        {
            MenuPrincipal menu = new MenuPrincipal();
            menu.ShowDialog();
        }
    }
}


