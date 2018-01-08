修改：/home/python-3.6.1/lib/python3.6/site-packages/Jinja2-2.9.6-py3.6.egg/jinja2/loaders.py
约160行，  155 
    156     .. versionchanged:: 2.8+
    157        The *followlinks* parameter was added.
    158     """
    159 
    160     def __init__(self, searchpath, encoding='gb2312', followlinks=False):
    161         if isinstance(searchpath, string_types):
    162             searchpath = [searchpath]
    163         self.searchpath = list(searchpath)
    164         self.encoding = encoding
    165         self.followlinks = followlinks

160的encoding赋值为gb2312
