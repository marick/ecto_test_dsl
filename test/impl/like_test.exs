defmodule Impl.Build.LikeTest do
  use TransformerTestSupport.Case
  import TransformerTestSupport.Impl.Like

  test "creating a `like` placeholder" do
    assert like(:earlier, except: %{b: 1}) == {:__like, :earlier, %{b: 1}}
    assert like(:earlier, except:  [b: 1]) == {:__like, :earlier, %{b: 1}}
    assert like(:earlier                 ) == {:__like, :earlier, %{    }}
  end

  describe "expanding likes" do
    test "nothing to expand" do
      earlier = []
      current = %{params: %{a: 3}}
      actual = expand_likes(earlier, current)
      assert actual == current
    end

    test "expanding one like" do 
      earlier = [ok:   %{params:           %{a: 1,  b: 2}}]
      current =        %{params: like(:ok, except: [b: 4])}
      actual = expand_likes(earlier, current)
      
      assert actual == %{params:           %{a: 1,  b: 4}}
    end
    
    test "a complete replacement" do
      earlier = [ok:   %{params:           %{a: 1,  b: 2}}]
      current =        %{params: like(:ok)}
      actual = expand_likes(earlier, current)
      
      assert actual == %{params:           %{a: 1,  b: 2}}
    end
  end
end
