alias EctoTestDSL.Parse.Node

defprotocol Node.EENable do
  def merge(node, more)
  def ensure_eens(node, default_module)
  def eens(node)
end

defprotocol Node.ParseTimeSubstitutable do 
  def substitute(node, examples)
end

defprotocol Node.RunTimeSubstitutable do 
  def substitute(node, neighborhood)
end

