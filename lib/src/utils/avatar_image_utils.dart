import 'package:flutter/material.dart';

class AvatarImageUtils extends StatelessWidget {
  const AvatarImageUtils(
      {super.key,
      required this.image,
      required this.sizeImage,
      this.name,
      this.color});
  final String? image;
  final double? sizeImage;
  final String? name;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return image != null && image!.isNotEmpty
        ? Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: sizeImage!,
                height: sizeImage!,
                child: const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage(
                    "images/image_no_avatar.jpg",
                  ),
                ),
              ),
              SizedBox(
                  width: sizeImage!.toInt() + 2,
                  height: sizeImage!.toInt() + 2,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: Image.network(errorBuilder:
                            (BuildContext context, Object exception,
                                StackTrace? stackTrace) {
                      return const SizedBox.shrink();
                    }, image!)
                        .image,
                  )),
            ],
          )
        : SizedBox(
            width: sizeImage,
            height: sizeImage,
            child: DefaultAvatar(
              name: name ?? "U",
              color: color ?? Colors.blueGrey.shade400,
            ));
  }
}

class DefaultAvatar extends StatelessWidget {
  final String name;
  final Color color;

  const DefaultAvatar({super.key, required this.name, required this.color});

  String getInitial() {
    String trimmed = name.trim();
    if (trimmed.isEmpty) return "?";
    List<String> words = trimmed.split(RegExp(r'\s+'));
    String lastWord = words.last;

    if (lastWord.isEmpty) return "?";

    String firstChar = lastWord[0];

    if (RegExp(r'[a-zA-Z0-9]').hasMatch(firstChar)) {
      return firstChar.toUpperCase();
    }

    return "?";
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        getInitial(),
        style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AvatarImageWithRadius extends StatelessWidget {
  const AvatarImageWithRadius(
      {super.key, required this.image, required this.sizeImage});
  final String? image;
  final double? sizeImage;

  @override
  Widget build(BuildContext context) {
    return image != null && image!.isNotEmpty
        ? Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: sizeImage, height: sizeImage,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  image: DecorationImage(
                    image: AssetImage("images/image_no_avatar.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                // other widget properties
              ),
              Container(
                width: sizeImage!.toInt() + 2, height: sizeImage!.toInt() + 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(
                      image!,
                    ),
                    onError: (error, stackTrace) {
                      // LogUtils.log('Image load failed: ','$error');
                    },
                    fit: BoxFit.cover,
                  ),
                ),
                // other widget properties
              ),
            ],
          )
        : Container(
            width: sizeImage, height: sizeImage,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              image: DecorationImage(
                image: AssetImage("images/image_no_avatar.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            // other widget properties
          );
  }
}
