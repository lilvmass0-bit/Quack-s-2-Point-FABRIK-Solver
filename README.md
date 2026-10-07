# Quack-s-2-Point-FABRIK-Solver

A prototype lightweight 2-point FABRIK solver for procedural gun slings, straps, and ropes in Roblox.

> **Important Setup Note:** This system is specifically designed for **Skinned Meshes** and **Roblox Bone objects**. It operates on bone hierarchies to procedurally deform meshes like weapon slings or tactical gear smoothly.
> 
> *Tip: If you don't know how to rig this, search for a **Roblox SmartBone rigging tutorial**, as the rigging process required for this solver is virtually identical.*
> 
> **Notice:** This is a prototype so it's kinda messy and basic. It doesn't use `ConnectParallel` because it's lightweight as it is and not fully scalable yet. If you want it scaled up, just ask an AI to adapt it using CollectionService tags or attributes. 
> 
> *Note: The included setup uses a ServerScript for the client wrapper by default, but you can easily move the logic completely client-sided for better performance and smoother replication.*

---

### 📥 Quick Download
* **[Download Solver Place (.rbxl)](https://github.com/lilvmass0-bit/Quack-s-2-Point-FABRIK-Solver/releases/download/v1.0.0/Quacks_2_Point_FABRIK_Solver.rbxl)**
* **[Download Solver Model (.rbxm)](https://github.com/lilvmass0-bit/Quack-s-2-Point-FABRIK-Solver/releases/download/v1.0.0/Quacks_2_Point_FABRIK_Solver.rbxm)**
* **[Download FBX Mesh & Texture (.fbx)](https://github.com/lilvmass0-bit/Quack-s-2-Point-FABRIK-Solver/releases/download/v1.0.0/fbx.zip)**

## 📁 How to Install

Choose the method that fits your workflow best:

* **Instant Test Place (`.rbxl`):** Open `Quacks_2_Point_FABRIK_Solver.rbxl` in Roblox Studio to see a fully working setup immediately.
* **Studio Model (`.rbxm`):** Drag and drop `Quacks_2_Point_FABRIK_Solver.rbxm` directly into your existing Roblox Studio place.
* **Raw Code:** Grab the source scripts directly from the `scripts/` folder if you use Rojo or want to manually paste them into your own objects.

### ⚠️ Critical FBX Import Instructions
If you are importing the included **FBX model** manually into Roblox Studio via the Asset Manager or 3D Importer, you **must change the scale settings**:
1. Open the **3D Importer** in Roblox Studio.
2. Select the FBX file.
3. Locate the **Scale** property under the model's import settings.
4. Set the **Scale value to exactly `0.0016`**.

> **Why this matters:** Skipping this step will cause the bone hierarchy and skinned mesh boundaries to mismatch, leaving the mesh completely **distorted and deformed** once the solver activates.

## ⚖️ License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. Created by lilvmass0-bit (QuackTheYuriNate).
