Toon Shader With Outline
=======

<img width="300" alt="result" src="https://user-images.githubusercontent.com/13420668/67771188-cfcd0580-fa92-11e9-832e-822b3d5105e2.png"><img width="310" alt="result" src="https://user-images.githubusercontent.com/13420668/67771198-d491b980-fa92-11e9-8aed-7192d89dee38.gif">
<img width="310" alt="result" src="https://user-images.githubusercontent.com/13420668/67771205-d6f41380-fa92-11e9-98e8-b0b70bd15a6d.gif"><img width="310" alt="result" src="https://user-images.githubusercontent.com/13420668/67771212-d8bdd700-fa92-11e9-96a1-444bef9de54f.gif">

    I use 2 extra shaders to generate screen space uv & normal map textures.
    Then. use *Roberts operator* to do the edge detection for normal, uv, depth.


Each texture's samping result can be toggled on/off.

<img width="500" alt="result" src="https://user-images.githubusercontent.com/13420668/67771219-dbb8c780-fa92-11e9-9c69-b03c4a9e3db2.png">

How To Use
-------------------
- Create an empty object and add *ToonCamera* component to it.

- Specific the toon layer on the *ToonCamera*. Only the selected layer will render by the camera's that generate uv/normal textures.

    ![Screen Shot 2019-10-29 at 9 45 23 PM](https://user-images.githubusercontent.com/13420668/67772683-74504700-fa95-11e9-8c51-688aa67de373.png)

Credits
======

The edge detection are mainly inspired by [Roystan Ross's blog], please go check it.

Also. thanks to [Thomas Poulet's Ni No Kuni 2: frame analysis] article.

[Roystan Ross's blog]: https://docs.unity3d.com/Manual/SL-ShaderReplacement.html
[Thomas Poulet's Ni No Kuni 2: frame analysis]: https://blog.thomaspoulet.fr/ninokuni2-frame/
