defprotocol EctoTestDSL.Parse.Node do
  def merge(node, more)
  def ensure_eens(node, default_module)
  def eens(node)
end
