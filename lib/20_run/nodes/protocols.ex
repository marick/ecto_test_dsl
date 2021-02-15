alias EctoTestDSL.Run.Rnode

defprotocol Rnode.Substitutable do
  def substitute(node, neighborhood)
end

