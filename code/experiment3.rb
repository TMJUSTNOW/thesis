require 'lib/metamodel'
M  = MetaModel

module MetaModel
  extend self

  def recommender_tasks(opts = {})
    {
      svd1:       Task.new({recommender: :svd, factorizer: :alswr, factorizer_features: 10}.merge(opts)),
      svd2:       Task.new({recommender: :svd, factorizer: :alswr, factorizer_features: 20}.merge(opts)),
      svd3:       Task.new({recommender: :svd, factorizer: :em, factorizer_features: 10}.merge(opts)),
      svd4:       Task.new({recommender: :svd, factorizer: :em, factorizer_features: 20}.merge(opts)),
      knn1:       Task.new({recommender: :generic_user}.merge(opts)),
      slope_one:  Task.new({recommender: :slope_one}.merge(opts)),
      baseline:   Task.new({recommender: :item_user_average}.merge(opts)),
      cosine:     Task.new({recommender: :generic_item}.merge(opts)) 
    }
  end
  
  def meta_tasks(recs, opts = {})
    {
      m_average: Task.new({recommender: :meta_basic, meta_method: :average, recommenders: recs.clone}.merge(opts)),
      m_median:  Task.new({recommender: :meta_basic, meta_method: :median,  recommenders: recs.clone}.merge(opts)),
    }
  end

  def stack_task(recs, opts = {})
    Task.new({
      recommender: :meta_basic,
      recommenders: recs.clone 
    }.merge(opts))
  end

  def evaluate(ranker, opts = {})
    result = Perform.perform(Task.new({
      mission: :rank_evaluator,
      recommenders: recommenders,
      ranker: ranker.clone
    }.merge(opts))).evaluate
    result
  end

  def recommenders(opts = {})
    rs = Perform.perform_all(M.recommender_tasks(opts))
    { stack: Perform.perform(M.stack_task(rs, opts)) }
  end

  def ranker(recs, opts = {})
    Ranker.new(Task.new({
      recommenders: recs.clone,
    }.merge(opts)))
  end
  
end

datasets = {
  d1: 'u1',
  #d2: 'u2',
  #d3: 'u3',
  #d4: 'u4',
  #d5: 'u5'
}
queries = [
  #"paris",
  '"new york" or washington'
  #"star trek",
  #"man life summer",
  #"man", "life", "day", "star", "time", "night", 
  #"paris", "city", "death", "boys", "king", "story", 
  #"home", "movie", "american", "sea", "world", "fear", 
  #"girl", "house", "secret", "bad", "family", "america", 
  #"chocolate" , "fire", "white", "bride", "woman", 
  #"summer"
]

queries.each do |q|
  M::Log.head('Query:',q)
  o = {
    #dataset: '/movielens/movielens-100k/meta/u.data',
    #testset: '/movielens/movielens-100k/meta/u.data',
    dataset: '/movielens/movielens-1mm/ratings.dat',
    testset: '/movielens/movielens-1mm/ratings.dat',
    query: q,
    ir_w: 1.0,
    number_of_results: 20,
    userid: 11
  }
  rs = M.recommenders(o)
  ranker = M.ranker(rs,o)
  ev = M.evaluate(ranker, o)
  puts
  puts "IR:"
  pp ev.first
  puts
  puts "Stack:"
  pp ev[1]
  puts
  puts "Combined:"
  pp ev.last
  puts
end






