class Post {
  String text, imageId, ratingsCount, ratingsAverage,postImage;
  int postId;
  List hashTags=List();
  List comments=List();

  Post(this.comments, this.text, this.postImage, this.ratingsCount, this.ratingsAverage, this.hashTags, this.postId);

}