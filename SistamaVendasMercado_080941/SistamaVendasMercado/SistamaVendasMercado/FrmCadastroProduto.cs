using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SistamaVendasMercado
{
    public partial class FrmCadastroProduto : Form
    {
        int produtoSelecionado = -1;

        public FrmCadastroProduto()
        {
            InitializeComponent();
            ConfigurarListView();
            CarregarProdutos();
        }

        void ConfigurarListView()
        {
            lvProdutos.Columns.Add("ID", 0);
            lvProdutos.Columns.Add("Produto", 150);
            lvProdutos.Columns.Add("Categoria", 100);
            lvProdutos.Columns.Add("Preço", 80);
            lvProdutos.Columns.Add("Stock", 70);
        }

        void CarregarProdutos()
        {
            lvProdutos.Items.Clear();
            using (SqlConnection con = Conexao.ObterConexao())
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Produtos ORDER BY ProdutoID DESC", con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                foreach (DataRow row in dt.Rows)
                {
                    ListViewItem item = new ListViewItem(row["ProdutoID"].ToString());
                    item.SubItems.Add(row["NomeProduto"].ToString());
                    item.SubItems.Add(row["Categoria"].ToString());
                    item.SubItems.Add(Convert.ToDecimal(row["PrecoUnitario"]).ToString("0.00"));
                    item.SubItems.Add(row["QuantidadeStock"].ToString());
                    lvProdutos.Items.Add(item);
                }
            }
        }


        private void btnSalvar_Click(object sender, EventArgs e)
        {

            if (string.IsNullOrWhiteSpace(txtNome.Text))
            {
                MessageBox.Show("Digite o nome do produto");
                return;
            }

            using (SqlConnection con = Conexao.ObterConexao())
            {
                string sql = produtoSelecionado == -1
                   ? "INSERT INTO Produtos (NomeProduto, Categoria, PrecoUnitario, QuantidadeStock) VALUES (@nome, @cat, @preco, @stock)"
                    : "UPDATE Produtos SET NomeProduto=@nome, Categoria=@cat, PrecoUnitario=@preco, QuantidadeStock=@stock WHERE ProdutoID=@id";

                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@nome", txtNome.Text);
                cmd.Parameters.AddWithValue("@cat", txtCategoria.Text);
                cmd.Parameters.AddWithValue("@preco", decimal.Parse(txtPreco.Text));
                cmd.Parameters.AddWithValue("@stock", int.Parse(txtStock.Text));
                if (produtoSelecionado != -1) cmd.Parameters.AddWithValue("@id", produtoSelecionado);

                con.Open();
                cmd.ExecuteNonQuery();
                MessageBox.Show("Salvo com sucesso!");
                Limpar();
                CarregarProdutos();
            }
        }

        private void lvProdutos_Click(object sender, EventArgs e)
        {
            if (lvProdutos.SelectedItems.Count > 0)
            {
                ListViewItem item = lvProdutos.SelectedItems[0];
                produtoSelecionado = int.Parse(item.SubItems[0].Text);
                txtNome.Text = item.SubItems[1].Text;
                txtCategoria.Text = item.SubItems[2].Text;
                txtPreco.Text = item.SubItems[3].Text;
                txtStock.Text = item.SubItems[4].Text;
            }
        }

        void Limpar()
        {
            txtNome.Clear(); txtCategoria.Clear(); txtPreco.Clear(); txtStock.Clear();
            produtoSelecionado = -1;
            txtNome.Focus();
        }

        private void btnLimpar_Click(object sender, EventArgs e)
        {

        }

        private void btnSair_Click(object sender, EventArgs e)
        {
            MenuPrincipal menu = new MenuPrincipal();
            menu.ShowDialog();
        }
    }
}