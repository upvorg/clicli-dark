class PostM {
  int id;
  String title;
  String content;
  String status;
  String sort;
  String tag;
  String time;
  int uid;
  String uname;
  String uqq;

  PostM(
      {this.id,
      this.title,
      this.content,
      this.status,
      this.sort,
      this.tag,
      this.time,
      this.uid,
      this.uname,
      this.uqq});

  PostM.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    status = json['status'];
    sort = json['sort'];
    tag = json['tag'];
    time = json['time'];
    uid = json['uid'];
    uname = json['uname'];
    uqq = json['uqq'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['status'] = this.status;
    data['sort'] = this.sort;
    data['tag'] = this.tag;
    data['time'] = this.time;
    data['uid'] = this.uid;
    data['uname'] = this.uname;
    data['uqq'] = this.uqq;
    return data;
  }
}
