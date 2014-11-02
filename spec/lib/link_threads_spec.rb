require 'rails_helper'

describe LinkThreads do
  describe ".link_threads" do
    it "links articles together based on parent_msgid" do
      art1 = Article.make!(msgid: "<abc>")
      art2 = Article.make!(msgid: "<def>", parent_msgid: "<abc>")

      LinkThreads.run

      art2.reload
      art2.parent_id.should eql(art1.id)
    end
  end

  describe ".link_threads" do
    it "links up conversations" do
      a1 = Article.make!
      a2 = Article.make!(parent_msgid: a1.msgid)
      LinkThreads.run
      a1.reload.conversation.should === a2.reload.conversation
    end

    it "handles out of order message arrival" do
      grandchild = Article.make!(msgid: "3", parent_msgid: "2")
      LinkThreads.run

      child = Article.make!(msgid: "2", parent_msgid: "1")
      LinkThreads.run

      [grandchild, child].each(&:reload)
      grandchild.conversation.should == child.conversation

      parent = Article.make!(msgid: "1")
      LinkThreads.run

      [grandchild, child, parent].each(&:reload)

      grandchild.conversation.should == child.conversation
      child.conversation.should == parent.conversation
    end

    it "merges conversations based on new information" do
      child1 = Article.make!(msgid: "3", parent_msgid: "1")
      child2 = Article.make!(msgid: "2", parent_msgid: "1")
      LinkThreads.run

      [child1, child2].each(&:reload)
      child1.conversation_id.should_not eq(child2.conversation_id)

      parent = Article.make!(msgid: "1")
      LinkThreads.run

      [parent, child1, child2].each(&:reload)
      child1.reload.conversation_id.should eq(parent.reload.conversation_id)
      child2.reload.conversation_id.should eq(parent.reload.conversation_id)

    end
  end
end
