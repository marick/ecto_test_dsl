alias EctoTestDSL.Parse.Node

defprotocol Node.EENable do
  def ensure_eens(node, default_module)
  def eens(node)
end

defprotocol Node.Mergeable do
  def merge(node, more)
end

defprotocol Node.ParseTimeSubstitutable do 
  def substitute(node, examples)
end

defprotocol Node.Exportable do 
  def export(node)
end

# This node can be thrown away during the export process
defprotocol Node.Deletable do
  def a_protocol_must_have_at_least_one_function(node)
end

