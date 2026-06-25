<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" indent="no"/>

  <xsl:template match="/rss/channel">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title><xsl:value-of select="title"/> — RSS feed</title>
        <link rel="preconnect" href="https://fonts.googleapis.com"/>
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,300;0,400;0,500;1,300;1,400&amp;family=Roboto+Mono:wght@400;500&amp;display=swap" rel="stylesheet"/>
        <style>
          :root {
            --bg:             #212631;
            --bg-card:        #1a1f2b;
            --border:         #2a3040;
            --border-hi:      #3a4560;
            --text-primary:   #dde1ea;
            --text-secondary: #7a8499;
            --text-muted:     #3d4760;
            --text-dim:       #2e3750;
            --accent:         #5a7ab0;
          }
          * { box-sizing: border-box; }
          html, body {
            margin: 0;
            background: var(--bg);
            color: var(--text-primary);
            font-family: 'Roboto', sans-serif;
            font-size: 14px;
          }
          .page {
            max-width: 680px;
            margin: 0 auto;
            padding: 56px 24px 80px;
          }
          .feed-title {
            font-size: 22px;
            font-weight: 500;
            margin: 0 0 6px;
            letter-spacing: 0.01em;
          }
          .feed-desc {
            font-size: 13px;
            color: var(--text-secondary);
            margin: 0 0 28px;
            line-height: 1.6;
          }
          .subscribe-box {
            background: var(--bg-card);
            border: 1px solid var(--border-hi);
            border-radius: 4px;
            padding: 20px 22px;
            margin-bottom: 40px;
          }
          .subscribe-label {
            font-size: 11px;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: var(--text-dim);
            margin: 0 0 10px;
          }
          .subscribe-text {
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.6;
            margin: 0 0 14px;
          }
          .subscribe-url {
            display: flex;
            align-items: center;
            gap: 10px;
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 3px;
            padding: 10px 12px;
          }
          .subscribe-url code {
            font-family: 'Roboto Mono', monospace;
            font-size: 12px;
            color: var(--text-primary);
            overflow-x: auto;
            white-space: nowrap;
            flex: 1;
          }
          .copy-btn {
            font-family: 'Roboto', sans-serif;
            font-size: 11px;
            letter-spacing: 0.04em;
            color: var(--text-primary);
            background: var(--bg-card);
            border: 1px solid var(--border-hi);
            border-radius: 2px;
            padding: 6px 10px;
            cursor: pointer;
            flex-shrink: 0;
            transition: border-color 0.15s, background 0.15s;
          }
          .copy-btn:hover { border-color: var(--text-muted); }
          .section-label {
            font-size: 11px;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: var(--text-dim);
            margin: 0 0 18px;
          }
          .entries {
            display: flex;
            flex-direction: column;
          }
          .entry {
            padding: 16px 0;
            border-top: 1px solid var(--border);
          }
          .entries .entry:last-child {
            border-bottom: 1px solid var(--border);
          }
          .entry-title {
            font-size: 14px;
            font-weight: 500;
            margin: 0 0 4px;
          }
          .entry-title a {
            color: var(--text-primary);
            text-decoration: none;
            border-bottom: 1px solid var(--border-hi);
            padding-bottom: 1px;
          }
          .entry-title a:hover { color: var(--accent); border-color: var(--accent); }
          .entry-desc {
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.6;
            margin: 0 0 6px;
          }
          .entry-date {
            font-size: 10px;
            color: var(--text-dim);
            letter-spacing: 0.06em;
            text-transform: uppercase;
            font-variant-numeric: tabular-nums;
          }
        </style>
      </head>
      <body>
        <div class="page">
          <p class="feed-title"><xsl:value-of select="title"/></p>
          <p class="feed-desc"><xsl:value-of select="description"/></p>

          <div class="subscribe-box">
            <p class="subscribe-label">This is an RSS feed</p>
            <p class="subscribe-text">
              To subscribe, copy this URL into your RSS reader of choice (e.g. Feedly, NetNewsWire, Miniflux).
            </p>
            <div class="subscribe-url">
              <code id="feed-url"><xsl:value-of select="link"/>rss.xml</code>
              <button class="copy-btn" onclick="
                var t = document.getElementById('feed-url').textContent;
                navigator.clipboard.writeText(t);
                this.textContent = 'copied';
                var b = this;
                setTimeout(function() {{ b.textContent = 'copy'; }}, 1500);
              ">copy</button>
            </div>
          </div>

          <p class="section-label">latest posts</p>
          <div class="entries">
            <xsl:for-each select="item">
              <div class="entry">
                <p class="entry-title">
                  <a href="{link}"><xsl:value-of select="title"/></a>
                </p>
                <xsl:if test="description != ''">
                  <p class="entry-desc"><xsl:value-of select="description"/></p>
                </xsl:if>
                <p class="entry-date"><xsl:value-of select="pubDate"/></p>
              </div>
            </xsl:for-each>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
