provider "local" {
}

resource "local_file" "foo" {
  filename = "${path.module}/foo.txt"
  content = "Hello World!"
}
