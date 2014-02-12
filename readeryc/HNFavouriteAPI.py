import sqlite3

def saveArticle(article):
    conn = sqlite3.connect("data/favourites.db")
    print(article)
    article = tuple(article)
    cursor = conn.cursor()
    cursor.execute("""CREATE TABLE IF NOT EXISTS articles
                      (title text, articleURL text, saveTime text,
                       poster text, numComments text, isAsk text,
                       domain text, points text, hnid text PRIMARY KEY)
                   """)


    # insert to table
    try:
        cursor.execute("INSERT INTO articles VALUES (?,?,?,?,?,?,?,?,?)", article)
        print("Article saved!")
        # save data to database
        conn.commit()
        return True
    except sqlite3.IntegrityError:
        print("Article already saved!")
        return False


def deleteArticle(hnid):
    conn = sqlite3.connect("data/favourites.db")

    hnid = str(hnid)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM articles WHERE hnid=?", (hnid,) )


    conn.commit()
    return True

def loadFavourites():
    conn = sqlite3.connect("data/favourites.db")

    cursor = conn.cursor()
    cursor.execute("""CREATE TABLE IF NOT EXISTS articles
              (title text, articleURL text, saveTime text,
               poster text, numComments text, isAsk text,
               domain text, points text, hnid text PRIMARY KEY)
            """)
    cursor.execute('SELECT * FROM articles')
    a = get_rowdicts(cursor)
    print(a)
    return a

def get_rowdicts(cursor):
    return list(cursor)
