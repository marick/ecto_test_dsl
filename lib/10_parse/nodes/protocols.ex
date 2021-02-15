alias EctoTestDSL.Parse.Pnode

defprotocol Pnode.EENable do
  def ensure_eens(node, default_module)
  def eens(node)
end

defprotocol Pnode.Mergeable do
  def merge(node, more)
end

defprotocol Pnode.Substitutable do 
  def substitute(node, examples)
end

defprotocol Pnode.Exportable do 
  def export(node)
end

# This node can be thrown away during the export process
defprotocol Pnode.Deletable do
  def a_protocol_must_have_at_least_one_function(node)
end

