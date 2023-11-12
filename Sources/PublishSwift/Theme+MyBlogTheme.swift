import Plot
import Publish

extension Theme {
    /// The default "Foundation" theme that Publish ships with, a very
    /// basic theme mostly implemented for demonstration purposes.
    static var myBlogTheme: Self {
        Theme(
            htmlFactory: MyBlogHTMLFactory(),
            resourcePaths: [
                "Resources/MyBlogTheme/styles.css",
                "Resources/MyBlogTheme/inter.ttf",
                "Resources/favicon.png",
                "Resources/favicon.ico",
                "Resources/robots.txt"
            ]
        )
    }
}

private struct MyBlogHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    Div {
                        Div {
                            Div {
                                Image("https://lh3.googleusercontent.com/pw/ADCreHc2x66qSYcgUtAAm7vrOXmMerMqKdszXQvitsd9yhzToqL-xfMYI-Npny-Vh8FSVYieEAwoyohTTwzRjy1Ce-4VWf5c4FihoZHMGZH27AhbRLPZuos=w2400").style("background-color:transparent").class("my-picture")
                            }.class("image-cropper")
                        }.class("table-cell")
                            Div {
                                Div {
                                    Text("Добро пожаловать! Меня зовут Сергей Попыванов, iOS-разработчик в Авито, немного барабанщик, веду персональную базу знаний, которая мне уже давно сильно жмет. Потренируюсь делиться полезностями. Подробнее обо мне ")
                                    Link("тут", url: "https://s.popyvanov.ru/posts/about-popyvanov-sergey")
                                    Text(".").addLineBreak().addLineBreak()
                                    Text("Цифровой сад - это место, где заметки продолжают жить после публикации")
                                }
                            }.class("table-cell-fixed")
                    }
                    .class("table")
                }
                Wrapper {
                    H2("Свежие статьи")
                    ItemList(
                        items: context.allItems(
                            sortedBy: \.date,
                            order: .descending
                        ),
                        site: context.site
                    )
                }
                SiteFooter()
            }
        )
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: section.id)
                Wrapper {
                    H1(section.title)
                    ItemList(items: section.items, site: context.site)
                }
                SiteFooter()
            }
        )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .class("item-page"),
                .components {
                    SiteHeader(context: context, selectedSelectionID: item.sectionID)
                    Wrapper {
                        Article {
                            Div(item.content.body).class("content")
                            //Span("Tagged with: ") пока теги для навигации не использую
                            ItemTagList(item: item, site: context.site)
                        }
                    }
                    SiteFooter()
                }
            )
        )
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper(page.body)
                SiteFooter()
            }
        )
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    H1("Browse all tags")
                    List(page.tags.sorted()) { tag in
                        ListItem {
                            Link(tag.string,
                                 url: context.site.path(for: tag).absoluteString
                            )
                        }
                        .class("tag")
                    }
                    .class("all-tags")
                }
                SiteFooter()
            }
        )
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    H1 {
                        Text("Tagged with ")
                        Span(page.tag.string).class("tag")
                    }

                    Link("Browse all tags",
                        url: context.site.tagListPath.absoluteString
                    )
                    .class("browse-all")

                    ItemList(
                        items: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.date,
                            order: .descending
                        ),
                        site: context.site
                    )
                }
                SiteFooter()
            }
        )
    }
}

private struct Wrapper: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Div(content: content).class("wrapper")
    }
}

private struct SiteHeader<Site: Website>: Component {
    var context: PublishingContext<Site>
    var selectedSelectionID: Site.SectionID?

    var body: Component {
        Header {
            Wrapper {
                Link(context.site.name, url: "/")
                    .class("site-name")

                if Site.SectionID.allCases.count > 1 {
                    navigation
                }
            }
        }
    }

    private var navigation: Component {
        Navigation {
            List(Site.SectionID.allCases) { sectionID in
                let section = context.sections[sectionID]

                return Link(section.title,
                    url: section.path.absoluteString
                )
                .class(sectionID == selectedSelectionID ? "selected" : "")
            }
        }
    }
}

private struct ItemList<Site: Website>: Component {
    var items: [Item<Site>]
    var site: Site

    var body: Component {
        List(items) { item in
            Article {
                H1(Link(item.title, url: item.path.absoluteString))
                ItemTagList(item: item, site: site)
                Paragraph(item.description)
            }
        }
        .class("item-list")
    }
}

private struct ItemTagList<Site: Website>: Component {
    var item: Item<Site>
    var site: Site

    var body: Component {
        List(item.tags) { tag in
            Link(tag.string, url: site.path(for: tag).absoluteString)
        }
        .class("tag-list")
    }
}

private struct SiteFooter: Component {
    var body: Component {
        Footer {
            Paragraph {
                Text("Сайт собран с помощью ")
                Link("Swift Publish", url: "https://github.com/johnsundell/publish")
            }
//            Paragraph {
//                Link("RSS feed", url: "/feed.rss")
//            }
        }
    }
}
