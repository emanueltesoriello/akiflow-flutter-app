class DocExt {
  static String titleFromConnectorId(String? connectorId) {
    switch (connectorId) {
      case "asana":
        return "Asana";
      case "clickup":
        return "ClickUp";
      case "dropbox":
        return "Dropbox";
      case "google":
        return "Google";
      case "gmail":
        return "Gmail";
      case "github":
        return "GitHub";
      case "jira":
        return "Jira";
      case "skype":
        return "Skype";
      case "teams":
        return "Teams";
      case "notion":
        return "Notion";
      case "slack":
        return "Slack";
      case "superhuman":
        return "Superhuman";
      case "todoist":
        return "Todoist";
      case "trello":
        return "Trello";
      case "twitter":
        return "Twitter";
      case "zapier":
        return "Zapier";
      case "zoom":
        return "Zoom";
      default:
        return connectorId ?? "";
    }
  }
}
