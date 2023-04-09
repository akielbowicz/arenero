import pandas
from collections import Counter,defaultdict
from csv import reader

ex = """ABC,ACGT,AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ABC,ACGT,AAAAAAAAAAAAAAAAAAAAAAAAAAAAA-
DEF,ACGT,AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
"""

# Monkey patching to have a cleaner interface
# disabled due to performance inpact
#def _add(self, key):
#    self[key] += 1
#Counter.add = _add

#Inheriting has the same degradation in performance
#from collections import Counter as __Counter
#class Counter(__Counter):
#    def _add(self, key):
#        self[key] += 1

#class _Counter(defaultdict):
#    """
#    Not fast enogh, .add incurrs many comparisons so has some
#    overhead
#    
#    TODO: incorrect implementation due to c[key] *= val not
#    updating most common 
#    """
#
#    def __init__(self, iterable=()):
#        super().__init__(lambda : 0)
#        self._most_common = None
#        self._most_common_count = 0
#        for e in iterable:
#            self.add(e)
#
#    def add(self, key):
#        self[key] += 1
#        v = self[key]
#        if v > self._most_common_count:
#            self._most_common = key
#            self._most_common_count = v
#
#    def most_common(self, n=1):
#        return [(self._most_common, self._most_common_count)]
#
#    def clear(self):
#        super().clear()
#        self._most_common = None
#        self._most_common_count = 0
#
#    def __repr__(self):
#        return f"Counter(most_common:{self.most_common()},{dict(self)})"

def read(input_text):
    lines = input_text.splitlines()
    return [l.split(',') for l in lines]

def read_csv(filepath):
    with open(filepath) as f:
        r = reader(f, delimiter="\t")
        next(r) # Skip header
        for l in r:
            yield l

def to_df(records):
    df0 = pandas.DataFrame(records, columns=["ids","clone_id"])
    names = df0["ids"]
    s = df0["clone_id"].apply(pandas.Series)
    df = pandas.merge(names,s,left_index=True,right_index=True)
    df.set_index("ids",inplace=True)
    return df
    
def agg_debug(x):
    print(f"type:{type(x)}")

def to_counter(x): 
    return Counter(x)

def most_common(counter):
    return counter.most_common(1)[0][0]

def mode(counter):
    """
    Counter enables to modify or add elements
    and if a queried value does not exist it assigns 0 counts to it
    """
    if len(counter) > 1:
	    counter["0"] *= 0.1
	    counter["-"] *= 0.1
    return most_common(counter)

def group(df):
    return df.groupby("ids").agg(to_counter)

def get_mode(df):
    return df.applymap(mode)

def join(iterable):
    return "".join(map(str,iterable))

def join_cols(df):
    return df.apply(join,axis=1)

def process_df(records):
    df = to_df(records)
    return (df.pipe(group)
       .pipe(get_mode)
       .pipe(join_cols)
    )
    
def test_dataframe():
    s = process_df(to_records(read(ex)))
    assert len(s) == 2
    assert type(s) is pandas.Series
    for line in s:
        assert len(line) == 30
        for char_ in line:
            assert char_ in ("A","C","G","T","0","-")

def to_groups(records):
    d = defaultdict(lambda: [Counter() for _ in range(30)])
    for cell_id, clone_id in records:
        e = d[cell_id]
        for counter, element in zip(e,clone_id):
            #counter.add(element)
            counter[element] += 1
    return d

def get_modes(counters):
    return join(mode(c) for c in counters)

def process_pure_python(records):
    groups = to_groups(records)
    return {k:get_modes(cs) for k,cs in groups.items()}

def test_pure_python():
    s = process_pure_python(to_records(read(ex)))
    assert len(s) == 2
    assert type(s) is dict
    for cell_id,line in s.items():
        assert len(line) == 30
        for char_ in line:
            assert char_ in ("A","C","G","T","0","-")

def main(path):
    return process_df(to_records(read_csv(path)))

def to_groups_lazy(records):
    recs = iter(records)
    current_cell, clone_id = next(recs)
    counters = [Counter([e]) for e in clone_id]
    
    for c_id,clone_id in recs:
        if current_cell == c_id:
            for counter, element in zip(counters, clone_id):
                counter[element] += 1
        else:
            yield current_cell, counters
            current_cell = c_id
            counters = [Counter([e]) for e in clone_id]
    yield current_cell, counters

def to_groups_lazy_2(records):
    recs = iter(records)
    current_cell, clone_id = next(recs)
    counter = Counter([clone_id])
    counters = [Counter() for _ in range(30)]
    for c_id, clone_id in recs:
        if current_cell == c_id:
           counter[clone_id] += 1
        else:
            
            for clone_id, count in counter.items(): 
                for c, element in zip(counters, clone_id):
                    c[element] += count
            yield current_cell, counters
            current_cell = c_id
            counter.clear()
            counter[clone_id] += 1
            counters = [Counter([e]) for e in clone_id]
    yield current_cell, counters
    
def process_sorted(records):
    groups = to_groups_lazy(records)
    return {k:get_modes(cs) for k,cs in groups}

def process_sorted_2(records):
    groups = to_groups_lazy_2(records)
    return {k:get_modes(cs) for k,cs in groups}

def encode(c): 
    """
       ACGTN0- 
       1374605
    """
    return ord(c)%8

encoding = {1:'A',3:'C',7:'G',4:'T',6:'N',0:'0',5:'-' }

def decode(d):
    return encoding[d]

def to_records(rows):
    for cell_id,umi,clone_id in rows:
        yield (f"{cell_id}{umi}",clone_id)
        
# Encoding the record does downgrade the performance a lot
def to_encoded_records(rows):
    for cell_id,umi,clone_id in rows:
        yield (int(join(map(encode,f"{cell_id}{umi}"))),list(map(encode,clone_id)))