require 'mailman'

describe "Config file parser" do
  before(:each) do
    @parser = Mailman::Parser.new
  end

  it "starts with no members" do
    @parser.members.should == []
  end

  it "accepts members" do
    @parser.accept("'members': {   'test@example.com': 0,")
    @parser.members.should == [ { email: 'test@example.com' } ]
  end

  it "case corrects email addresses when given" do
    @parser.accept("'members': {   'test@example.com': 'Test@Example.COM',")
    @parser.members.should == [ { email: 'Test@Example.COM' } ]
  end

  it "accepts multiple members" do
    @parser.accept("'members': {   'test@example.com': 0,")
    @parser.accept("               'test2@example.com': 0,")
    @parser.members.should == [ { email: "test@example.com" },
                                { email: "test2@example.com" } ]
  end

  it "accepts the last member and changes state" do
    @parser.accept("'members': {   'test@example.com': 0,")
    @parser.accept("               'test2@example.com': 0},")
    @parser.members.should == [ { email: "test@example.com" },
                                { email: "test2@example.com" } ]
    @parser.section.should be_nil
  end

  it "augments data with new info" do
    @parser.accept("'members': { 'test@example.com': 0 },")
    @parser.accept("'usernames': { 'test@example.com': u'Joe Test',")

    @parser.members.should == [ { email: "test@example.com", name: "Joe Test" }]
  end

  it "takes sections in any order" do
    @parser.accept("'usernames': { 'test@example.com': u'Joe Test',")
    @parser.accept("'members': { 'test@example.com': 0 },")

    @parser.members.should == [ { email: "test@example.com", name: "Joe Test" }]
  end

  it "understands the password section" do
    @parser.accept("'passwords': { 'test@example.com': 'secret',")
    @parser.members.should == [ { password: 'secret' }]
  end

  it "adds moderated: true to moderated users" do
    @parser.accept("'user_options': { 'test@example.com': 128,")  # 128 is Mailman's "moderated" flag
    @parser.members.should == [ { email: 'test@example.com', moderated: true }]
  end

  it "does not add :moderated for unmoderated users" do
    @parser.accept("'user_options': { 'test@example.com': 0,")
    @parser.members.should == [ { email: 'test@example.com' }]
  end

  it "adds digest: true to digest members" do
    @parser.accept("'digest_members': { 'test@example.com': 0,")
    @parser.members.should == [ { email: 'test@example.com', digest: true }]
  end

  it "copes with both :digest and :moderated options" do
    @parser.accept("'user_options': { 'test@example.com': 128,")
    @parser.accept("'digest_members': { 'test@example.com': 0,")
    @parser.members.should == [ { email: 'test@example.com', digest: true, moderated: true }]
  end

  it "adds nomail: true when needed" do
    @parser.accept("'members': {   'test@example.com': 0,")
    @parser.accept("'delivery_status': {   'test@example.com': (2")
    @parser.members.should == [ { email: 'test@example.com', nomail: true }]
  end
end
