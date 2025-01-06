enum StringXMLMocks {
    static let missingUrlRawXml = """
<rss xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
    <channel>
        <title>
            <![CDATA[ BBC News ]]>
        </title>
        <description>
            <![CDATA[ BBC News ]]>
        </description>
        <image>
            <url>https://news.bbcimg.co.uk/nol/shared/img/bbc_news_120x60.gif</url>
        </image>
    </channel>
</rss>
"""

    static let missingTitleRawXml = """
<rss xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
    <channel>
        <description>
            <![CDATA[ BBC News - World ]]>
        </description>
        <link>https://www.bbc.co.uk/news/world</link>
        <image>
            <url>https://news.bbcimg.co.uk/nol/shared/img/bbc_news_120x60.gif</url>
        </image>
    </channel>
</rss>
"""

    static let missingDescriptionRawXml = """
<rss xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
    <channel>
        <title>
            <![CDATA[ BBC News ]]>
        </title>
        <link>https://www.bbc.co.uk/news/world</link>
        <image>
            <url>https://news.bbcimg.co.uk/nol/shared/img/bbc_news_120x60.gif</url>
        </image>
    </channel>
</rss>
"""

    static let zeroItemsRawXml = """
<rss xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
    <channel>
        <title>
            <![CDATA[ BBC News ]]>
        </title>
        <description>
            <![CDATA[ BBC News - World ]]>
        </description>
        <link>https://www.bbc.co.uk/news/world</link>
        <image>
            <url>https://news.bbcimg.co.uk/nol/shared/img/bbc_news_120x60.gif</url>
        </image>
    </channel>
</rss>
"""

    static let multipleItemsRawXml = """
<rss xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
    <channel>
        <title>
            <![CDATA[ BBC News ]]>
        </title>
        <description>
            <![CDATA[ BBC News - World ]]>
        </description>
        <link>https://www.bbc.co.uk/news/world</link>
        <image>
            <url>https://news.bbcimg.co.uk/nol/shared/img/bbc_news_120x60.gif</url>
        </image>
        <item>
            <title>
                <![CDATA[ Could bike lanes reshape car-crazy Los Angeles? ]]>
            </title>
            <description>
                <![CDATA[ LA is trying to expand its cycling network ahead of the 2028 Olympics, but some are skeptical. ]]>
            </description>
            <link>https://www.bbc.com/news/articles/c3vrzelzdrlo</link>
            <guid isPermaLink="false">https://www.bbc.com/news/articles/c3vrzelzdrlo#3</guid>
            <pubDate>Wed, 01 Jan 2025 02:42:33 GMT</pubDate>
            <media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/39d2/live/e5809720-bee6-11ef-89fe-61878ce1042c.jpg"/>
        </item>
    </channel>
</rss>
"""
}
