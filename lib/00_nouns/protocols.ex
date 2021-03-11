alias EctoTestDSL.Nouns

defprotocol Nouns.RefHolder do
  def eens(node)
  def dereference(node, neighborhood)
end

