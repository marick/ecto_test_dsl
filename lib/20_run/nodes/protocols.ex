alias EctoTestDSL.Run.Rnode

defprotocol Rnode.RunTimeSubstitutable do
  def substitute(node, neighborhood)
end

